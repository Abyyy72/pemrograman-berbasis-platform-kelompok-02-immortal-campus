<script lang="ts">
  import DashboardPenulis from '../components/DashboardPenulis.svelte';
  import type { Karya } from '../types';

  interface Props {
    karyaList: Karya[];
    userName?: string;
    currentUser?: any;
    onClose: () => void;
    onLogout?: () => void;
    onOpenEdit: (karya: Karya) => void;
    onOpenDetail: (karya: Karya) => void;
    onOpenUpload: () => void;
    onOpenPanduan?: () => void;
    onNavigateJelajah?: () => void;
    onNavigateHome?: () => void;
  }

  let {
    karyaList,
    userName = 'Amanda Putri Wibowo',
    currentUser = null,
    onClose,
    onLogout,
    onOpenEdit,
    onOpenDetail,
    onOpenUpload,
    onOpenPanduan,
    onNavigateJelajah,
    onNavigateHome
  }: Props = $props();
</script>

<DashboardPenulis
  isOpen={true}
  {karyaList}
  {userName}
  {currentUser}
  {onClose}
  {onLogout}
  {onOpenEdit}
  {onOpenDetail}
  {onOpenUpload}
  {onOpenPanduan}
  {onNavigateJelajah}
  {onNavigateHome}
/>
