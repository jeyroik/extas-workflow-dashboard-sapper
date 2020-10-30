<script>
    export let valueInput
    export let value
</script>
<svelte:options accessors/>
<input bind:this={valueInput} bind:value={value} id="_" class="form-control"/>