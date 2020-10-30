<script>
    import Filter from '../inputs/Filter.svelte'

    export let filters
    export let items
    export let afterFilterHook

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
                <Filter bind:items={items} field="{filter.field}" sub={filter.sub} bind:value={filter.value} afterFilter={afterFilterHook}/>
            </td>
        {/if}
    {/each}
    <td>
        <button class="btn btn-default" on:click={resetFilter} title="Очистить фильтр" value="">
            <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-funnel" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M1.5 1.5A.5.5 0 0 1 2 1h12a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-.128.334L10 8.692V13.5a.5.5 0 0 1-.342.474l-3 1A.5.5 0 0 1 6 14.5V8.692L1.628 3.834A.5.5 0 0 1 1.5 3.5v-2zm1 .5v1.308l4.372 4.858A.5.5 0 0 1 7 8.5v5.306l2-.666V8.5a.5.5 0 0 1 .128-.334L13.5 3.308V2h-11z"/>
            </svg>
        </button>
    </td>
</tr>
