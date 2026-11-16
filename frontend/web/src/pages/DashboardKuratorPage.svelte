<script lang="ts">
  import DashboardKurator from '../components/DashboardKurator.svelte';
  import type { Karya } from '../types';

  interface Props {
    karyaList: Karya[];
    pendingCount: number;
    currentUser?: any;
    onClose: () => void;
    onLogout?: () => void;
    onOpenReview: (karya: Karya) => void;
    onOpenDetail: (karya: Karya) => void;
    onDownloadKarya?: (karya: Karya) => void;
    onNavigateHome?: () => void;
    onNavigateJelajah?: () => void;
  }

  let {
    karyaList,
    pendingCount,
    currentUser = null,
    onClose,
    onLogout,
    onOpenReview,
    onOpenDetail,
    onDownloadKarya,
    onNavigateHome,
    onNavigateJelajah
  }: Props = $props();
</script>

<DashboardKurator
  isOpen={true}
  {karyaList}
  {pendingCount}
  {currentUser}
  {onClose}
  {onLogout}
  {onOpenReview}
  {onOpenDetail}
  {onDownloadKarya}
  {onNavigateHome}
  {onNavigateJelajah}
/>
