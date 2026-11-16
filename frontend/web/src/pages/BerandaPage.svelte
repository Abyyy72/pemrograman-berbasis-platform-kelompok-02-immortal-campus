<script lang="ts">
  import HeroSection from '../components/HeroSection.svelte';
  import ValueProposition from '../components/ValueProposition.svelte';
  import JelajahKarya from '../components/JelajahKarya.svelte';
  import StatistikSection from '../components/StatistikSection.svelte';
  import AlurKurasi from '../components/AlurKurasi.svelte';
  import PanduanSection from '../components/PanduanSection.svelte';

  import type { Karya, RolePengguna } from '../types';
  import type { StatistikData } from '../lib/api';

  interface Props {
    karyaList: Karya[];
    statistikData?: StatistikData | null;
    activeRole: RolePengguna;
    searchQuery: string;
    selectedCategory: string;
    selectedProdiKey: 'all' | 'ti' | 'si' | 'dkv' | 'mnj' | 'ilkom';
    onSearchChange: (q: string) => void;
    onProdiSelect: (k: 'all' | 'ti' | 'si' | 'dkv' | 'mnj' | 'ilkom') => void;
    onCategoryChange: (cat: string) => void;
    onOpenUpload: () => void;
    onOpenDetail: (karya: Karya) => void;
    onDownloadKarya: (karya: Karya) => void;
    onOpenReviewModal: (karya: Karya) => void;
    onOpenEdit: (karya: Karya) => void;
    onOpenPanduanModal: () => void;
    onProdiFilterSelect: (name: string) => void;
    onDownloadLeaderboard: (title: string) => void;
  }

  let {
    karyaList,
    statistikData = null,
    activeRole,
    searchQuery,
    selectedCategory,
    selectedProdiKey,
    onSearchChange,
    onProdiSelect,
    onCategoryChange,
    onOpenUpload,
    onOpenDetail,
    onDownloadKarya,
    onOpenReviewModal,
    onOpenEdit,
    onOpenPanduanModal,
    onProdiFilterSelect,
    onDownloadLeaderboard
  }: Props = $props();
</script>

<div class="flex flex-col w-full">
  <!-- 2. HERO SECTION -->
  <HeroSection
    {karyaList}
    {searchQuery}
    {selectedProdiKey}
    {onSearchChange}
    {onProdiSelect}
    {onOpenUpload}
    {onOpenDetail}
    {onDownloadKarya}
  />

  <!-- 3. VALUE PROPOSITION SECTION -->
  <ValueProposition />

  <!-- 4. BAGIAN EKSPLORASI KARYA POPULER & TERBARU -->
  <JelajahKarya
    {karyaList}
    {activeRole}
    {selectedCategory}
    {searchQuery}
    {selectedProdiKey}
    {onCategoryChange}
    {onOpenDetail}
    {onDownloadKarya}
    {onOpenReviewModal}
    {onOpenEdit}
  />

  <!-- 5, 6, 7. STATISTIK, DIREKTORI FAKULTAS, LEADERBOARD -->
  <StatistikSection
    {karyaList}
    {statistikData}
    onSelectProdi={onProdiFilterSelect}
    onDownloadLeaderboard={onDownloadLeaderboard}
  />

  <!-- 8. ALUR KURASI NASKAH TRANSPARAN & CEPAT -->
  <AlurKurasi />

  <!-- 9. BANNER SOLUSI BORANG AKREDITASI KRITERIA 9 & CTA -->
  <PanduanSection
    {onOpenUpload}
    {onOpenPanduanModal}
  />
</div>

