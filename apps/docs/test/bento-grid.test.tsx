import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import {
  BentoGrid,
  BentoZeroDependency,
  BentoContrastAuditor,
  BentoAspectRebuild,
  BentoNeobrutalism,
  BentoCliWorkflow,
} from '@/components/organisms/bento';

describe('BentoGrid and 5 Engineering Cards', () => {
  describe('BentoGrid Container', () => {
    it('renders the engine room header and all 5 cards in English', () => {
      render(<BentoGrid lang="en" />);

      expect(screen.getByText('THE ENGINE ROOM')).toBeInTheDocument();
      expect(
        screen.getByRole('heading', {
          name: /engineered for extreme performance/i,
        })
      ).toBeInTheDocument();
      expect(screen.getByText('Zero-Dependency Footprint')).toBeInTheDocument();
      expect(screen.getByText('Dynamic Contrast Auditor')).toBeInTheDocument();
      expect(screen.getByText('Aspect-Based Rebuilds')).toBeInTheDocument();
      expect(screen.getByText('Neobrutalism Zero-Drift')).toBeInTheDocument();
      expect(screen.getByText('Dart 3 Expressive DX')).toBeInTheDocument();
    });

    it('renders localized Indonesian header and cards', () => {
      render(<BentoGrid lang="id" />);

      expect(screen.getByText('RUANG MESIN ARSITEKTUR')).toBeInTheDocument();
      expect(
        screen.getByRole('heading', {
          name: /direkayasa untuk performa ekstrem/i,
        })
      ).toBeInTheDocument();
      expect(screen.getByText('Jejak Nol-Dependensi')).toBeInTheDocument();
      expect(screen.getByText('Auditor Kontras Dinamis')).toBeInTheDocument();
      expect(screen.getByText('Rebuild Berbasis Aspek')).toBeInTheDocument();
      expect(
        screen.getByText('Fisika Zero-Drift Neobrutalisme')
      ).toBeInTheDocument();
      expect(
        screen.getByText('Pengalaman Pengembang Dart 3')
      ).toBeInTheDocument();
    });
  });

  describe('Card 1: BentoZeroDependency', () => {
    it('toggles between Traditional Pub and JustUI 0 Dep modes', () => {
      render(
        <BentoZeroDependency
          title="Zero-Dependency Footprint"
          description="Test description"
        />
      );

      // Initially in JustUI mode
      expect(screen.getByText('0 external dependencies')).toBeInTheDocument();
      expect(screen.getByText('ZERO VECTOR (0)')).toBeInTheDocument();

      // Click Traditional Pub button
      const tradButton = screen.getByRole('button', {
        name: /traditional pub/i,
      });
      fireEvent.click(tradButton);

      expect(screen.getByText('14 packages / 4.2 MB')).toBeInTheDocument();
      expect(screen.getByText('HIGH SURFACE (14+)')).toBeInTheDocument();

      // Click on a dependency node
      const intlNode = screen.getByRole('button', { name: /intl/i });
      fireEvent.click(intlNode);

      // Toggle back to JustUI
      const justuiButton = screen.getByRole('button', {
        name: /justui \(0 dep\)/i,
      });
      fireEvent.click(justuiButton);
      expect(screen.getByText('0 external dependencies')).toBeInTheDocument();
    });
  });

  describe('Card 2: BentoContrastAuditor', () => {
    it('calculates contrast ratio and toggles auto-enforce AA', () => {
      render(
        <BentoContrastAuditor
          title="Dynamic Contrast Auditor"
          description="Test contrast auditor"
        />
      );

      expect(screen.getByText('ACCESSIBILITY (A11Y)')).toBeInTheDocument();
      expect(screen.getByText(/Text:/i)).toBeInTheDocument();
      expect(screen.getByText(/Border:/i)).toBeInTheDocument();

      // Toggle Auto-Enforce AA button
      const enforceButton = screen.getByRole('button', {
        name: /auto-enforce aa: off/i,
      });
      fireEvent.click(enforceButton);
      expect(
        screen.getByRole('button', { name: /auto-enforce aa: on/i })
      ).toBeInTheDocument();

      // Drag slider
      const slider = screen.getByRole('slider', { name: /lightness/i });
      fireEvent.change(slider, { target: { value: '20' } });
      expect(screen.getByText(/Background Lightness/i)).toBeInTheDocument();
    });
  });

  describe('Card 3: BentoAspectRebuild', () => {
    it('switches active aspects and shows selective dirty nodes', () => {
      render(
        <BentoAspectRebuild
          title="Aspect-Based Rebuilds"
          description="Test aspect rebuilds"
        />
      );

      // Default aspect is colors
      expect(screen.getByText('Aspect: COLORS')).toBeInTheDocument();
      expect(screen.getByText('JustButton')).toBeInTheDocument();

      // Switch to typography
      const typoButton = screen.getByRole('button', { name: /typography/i });
      fireEvent.click(typoButton);
      expect(screen.getByText('Aspect: TYPOGRAPHY')).toBeInTheDocument();

      // Switch to spacing
      const spacingButton = screen.getByRole('button', { name: /spacing/i });
      fireEvent.click(spacingButton);
      expect(screen.getByText('Aspect: SPACING')).toBeInTheDocument();
      expect(screen.getByText('PaddingBox')).toBeInTheDocument();
    });
  });

  describe('Card 4: BentoNeobrutalism', () => {
    it('supports mouse down/up press interaction and switch toggle', () => {
      render(
        <BentoNeobrutalism
          title="Neobrutalism Zero-Drift"
          description="Test neobrutalism"
        />
      );

      expect(screen.getByText('PHYSICS & CALCULUS')).toBeInTheDocument();

      // Button press interaction
      const pressButton = screen.getByRole('button', { name: /press me/i });
      fireEvent.mouseDown(pressButton);
      expect(screen.getByText('Pressed')).toBeInTheDocument();
      expect(screen.getByText('T: (4px, 4px)')).toBeInTheDocument();

      fireEvent.mouseUp(pressButton);
      expect(screen.getByText('Press Me')).toBeInTheDocument();
      expect(screen.getByText('T: (0px, 0px)')).toBeInTheDocument();

      // Switch toggle
      const switchToggle = screen.getByRole('button', {
        name: '',
      });
      fireEvent.click(switchToggle);
      expect(screen.getByText(/Thumb D = 21px/i)).toBeInTheDocument();
    });
  });

  describe('Card 5: BentoCliWorkflow', () => {
    it('toggles code tabs between JustUI dot-shorthand and verbose', () => {
      render(
        <BentoCliWorkflow
          title="Dart 3 Expressive DX"
          description="Test CLI workflow"
        />
      );

      expect(screen.getByText('DEVELOPER EXPERIENCE (DX)')).toBeInTheDocument();
      expect(screen.getByText('justui add button')).toBeInTheDocument();

      // Default is JustUI code
      expect(
        screen.getByText(/JustUI Dart Dot-Shorthand/i)
      ).toBeInTheDocument();

      // Switch to verbose tab
      const verboseButton = screen.getByRole('button', {
        name: /standard verbose/i,
      });
      fireEvent.click(verboseButton);

      expect(screen.getByText(/Standard Verbose Flutter/i)).toBeInTheDocument();

      // Switch back
      const justuiButton = screen.getByRole('button', {
        name: /justui dot-shorthand/i,
      });
      fireEvent.click(justuiButton);
      expect(
        screen.getByText(/JustUI Dart Dot-Shorthand/i)
      ).toBeInTheDocument();
    });
  });
});
