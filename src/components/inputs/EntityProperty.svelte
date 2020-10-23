<script>
    export let value
    export let title = value
    export let editable = true
</script>

{#if editable}
    <input bind:value={value} type="text" class="silent-input-text" title="{title}">
{:else}
    <input bind:value={value} type="text" class="silent-input-text" title="{title}" readonly>
{/if}