<script context="module">
    export function extractFilter(field, jsonRpcFilter) {
        if (jsonRpcFilter[field] !== undefined) {
            return jsonRpcFilter[field]['$in'].pop()
        }
        return ''
    }
</script>