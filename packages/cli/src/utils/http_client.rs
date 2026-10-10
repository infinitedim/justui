//! Centralized HTTP client and network communication helpers.
//!
//! # Invariants
//! - Connect timeout is fixed to 5s.
//! - Total timeout is 15s default, overridable by `JUSTUI_HTTP_TIMEOUT`.
//! - `User-Agent: justui/<version>` is strictly enforced.
//! - Non-localhost plain HTTP URLs are rejected.
//! - GET retries with exponential backoff on connect errors, timeouts, and 5xx only.

use std::time::Duration;
use thiserror::Error;

/// Environment variable for HTTP timeout override.
pub const JUSTUI_HTTP_TIMEOUT_ENV: &str = "JUSTUI_HTTP_TIMEOUT";

const DEFAULT_HTTP_TIMEOUT_SECS: u64 = 15;
const CONNECT_TIMEOUT_SECS: u64 = 5;
const MAX_RETRIES: usize = 3;

/// Errors arising from HTTP operations.
#[derive(Debug, Error)]
pub enum HttpClientError {
    /// Insecure plain HTTP protocol rejected.
    #[error("insecure http protocol rejected for remote url: {0}")]
    InsecureHttp(String),

    /// HTTP request failed.
    #[error("http request failed: {0}")]
    RequestFailed(#[from] reqwest::Error),

    /// Server returned an error status code.
    #[error("http server returned status {status} for {url}")]
    StatusError {
        url: String,
        status: reqwest::StatusCode,
    },
}

/// Validates that a URL is secure HTTPS, localhost, or a local path.
///
/// # Errors
/// Returns `HttpClientError::InsecureHttp` if plain HTTP is used on non-localhost hosts.
pub fn validate_url(url: &str) -> Result<(), HttpClientError> {
    if let Some(rest) = url.strip_prefix("http://") {
        let host = rest
            .split('/')
            .next()
            .unwrap_or("")
            .split(':')
            .next()
            .unwrap_or("");
        if host != "localhost" && host != "127.0.0.1" && host != "::1" {
            return Err(HttpClientError::InsecureHttp(url.to_string()));
        }
    }
    Ok(())
}

/// Resolves total HTTP timeout from `JUSTUI_HTTP_TIMEOUT` or defaults to 15s.
#[must_use]
pub fn resolve_timeout() -> Duration {
    let secs = std::env::var(JUSTUI_HTTP_TIMEOUT_ENV)
        .ok()
        .and_then(|raw| raw.trim().parse::<u64>().ok())
        .filter(|&s| s > 0)
        .unwrap_or(DEFAULT_HTTP_TIMEOUT_SECS);
    Duration::from_secs(secs)
}

/// Builds the centralized `reqwest::Client`.
///
/// # Errors
/// Returns `HttpClientError::RequestFailed` if client configuration is invalid.
pub fn make_client() -> Result<reqwest::Client, HttpClientError> {
    let user_agent = format!("justui/{}", env!("CARGO_PKG_VERSION"));
    reqwest::Client::builder()
        .connect_timeout(Duration::from_secs(CONNECT_TIMEOUT_SECS))
        .timeout(resolve_timeout())
        .user_agent(user_agent)
        .build()
        .map_err(HttpClientError::RequestFailed)
}

/// Executes a GET request with exponential backoff on retryable failures.
///
/// Retries on connect errors, timeouts, and 5xx status codes.
/// Rejects without retry on 4xx codes or insecure protocols.
///
/// # Errors
/// Returns `HttpClientError` if the request ultimately fails or returns non-success.
pub async fn get_with_retry(
    client: &reqwest::Client,
    url: &str,
) -> Result<reqwest::Response, HttpClientError> {
    validate_url(url)?;

    let mut delay = Duration::from_millis(150);
    let mut last_error: Option<HttpClientError> = None;

    for attempt in 0..MAX_RETRIES {
        if attempt > 0 {
            tokio::time::sleep(delay).await;
            delay *= 2;
        }

        match client.get(url).send().await {
            Ok(resp) => {
                let status = resp.status();
                if status.is_success() {
                    return Ok(resp);
                }
                if status.is_server_error() {
                    last_error = Some(HttpClientError::StatusError {
                        url: url.to_string(),
                        status,
                    });
                    continue;
                }
                return Err(HttpClientError::StatusError {
                    url: url.to_string(),
                    status,
                });
            }
            Err(e) => {
                if e.is_connect() || e.is_timeout() {
                    last_error = Some(HttpClientError::RequestFailed(e));
                    continue;
                }
                return Err(HttpClientError::RequestFailed(e));
            }
        }
    }

    Err(last_error.unwrap_or_else(|| HttpClientError::StatusError {
        url: url.to_string(),
        status: reqwest::StatusCode::INTERNAL_SERVER_ERROR,
    }))
}

/// Convenience helper to fetch response body as string with retry.
///
/// # Errors
/// Returns `HttpClientError` on fetch or text decode failure.
pub async fn get_with_retry_text(
    client: &reqwest::Client,
    url: &str,
) -> Result<String, HttpClientError> {
    let resp = get_with_retry(client, url).await?;
    resp.text().await.map_err(HttpClientError::RequestFailed)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_url_allows_https_and_localhost() {
        assert!(validate_url("https://example.com/registry/index.json").is_ok());
        assert!(validate_url("http://localhost:8080/index.json").is_ok());
        assert!(validate_url("http://127.0.0.1:8080/index.json").is_ok());
        assert!(validate_url("/local/path/index.json").is_ok());
    }

    #[test]
    fn test_validate_url_rejects_insecure_remote_http() {
        assert!(validate_url("http://insecure.example.com/index.json").is_err());
    }

    #[test]
    fn test_make_client_builds() {
        assert!(make_client().is_ok());
    }
}
