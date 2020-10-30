<script>
    export let items
    export let field
    export let sub = null
    export let value = ''
    export let afterFilter

    let source = items

    function filterByField(query) {
        let items = source;

        if ((typeof query == 'undefined') || (query === '')) {
            items = source.filter(item => true)
        } else if (sub === null) {
            items = source.filter(item => item[field].toLowerCase().indexOf(query.toLowerCase()) != -1)
        } else {
            items = source.filter(item => {
                return item[field][sub].toLowerCase().indexOf(query.toLowerCase()) != -1
            })
        }

        return items
    }

    function filter() {
        items = filterByField(value)

        if (typeof afterFilter !== 'undefined') {
            afterFilter(items, value)
        }
    }

    if (value !== '') {
        filter()
    }
</script>

<input placeholder="фильтр" bind:value={value} type="text" on:input={filter}/>