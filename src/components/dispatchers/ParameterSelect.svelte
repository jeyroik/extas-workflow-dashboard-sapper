<script>
    export let items
    export let value
</script>
<svelte:options accessors/>
<select class="form-control" bind:value={value} on:change id="">
    {#each items as item}
        <option value="{item.name}" title="{item.description}">{item.title}</option>
    {/each}
</select>