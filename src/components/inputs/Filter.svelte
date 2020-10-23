<script>
    export let items
    export let field
    export let sub = null
    export let value = ''

    let source = items

    function filter() {
        items = items.filterByField(source, value, field, sub)
    }

    if (value !== '') {
        filter()
    }
</script>

<input placeholder="фильтр" bind:value={value} type="text" on:input={filter}/>