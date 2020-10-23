<script>
    import Filter from '../inputs/Filter.svelte'

    export let filters
    export let items

    let source = items

    function resetFilter() {
        filters = filters.filter(item => {
            item.value = ''
            return true
        })
        items = source
    }
</script>

<tr>
    {#each filters as filter}
        {#if filter.empty}
            <td></td>
        {:else}
            <td>
                <Filter bind:items={items} field="{filter.field}" sub={filter.sub} bind:value={filter.value}/>
            </td>
        {/if}
    {/each}
    <td>
        <button class="btn btn-default" on:click={resetFilter} title="Очистить фильтр" value="">
            <span class="glyphicon glyphicon-ban-circle" aria-hidden="true"></span>
        </button>
    </td>
</tr>
