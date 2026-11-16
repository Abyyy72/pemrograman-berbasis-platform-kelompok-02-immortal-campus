<script lang="ts">
  import type { Karya } from '../types';
  import DashboardAdmin from '../components/DashboardAdmin.svelte';

  interface Props {
    karyaList: Karya[];
    currentUser?: any;
    onClose: () => void;
    onLogout?: () => void;
    onOpenDetail?: (karya: Karya) => void;
    onNavigateHome?: () => void;
    onNavigateJelajah?: () => void;
  }

  let {
    karyaList,
    currentUser = null,
    onClose,
    onLogout,
    onOpenDetail,
    onNavigateHome,
    onNavigateJelajah
  }: Props = $props();
</script>

<DashboardAdmin
  {karyaList}
  {currentUser}
  {onClose}
  {onLogout}
  {onOpenDetail}
  {onNavigateHome}
  {onNavigateJelajah}
/>
