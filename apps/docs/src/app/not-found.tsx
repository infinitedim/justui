import { NotFoundView } from '@/components/organisms/not-found-view';
import { fetchStarCount } from '@/lib/github';

export default async function NotFound() {
  const starCount = await fetchStarCount();
  return <NotFoundView starCount={starCount} />;
}
