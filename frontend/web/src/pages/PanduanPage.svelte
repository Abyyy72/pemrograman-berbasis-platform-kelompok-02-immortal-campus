<script lang="ts">
  import PanduanSection from '../components/PanduanSection.svelte';

  interface Props {
    onOpenUpload: () => void;
  }

  let { onOpenUpload }: Props = $props();
</script>

<div class="w-full">
  <PanduanSection {onOpenUpload} />
</div>
