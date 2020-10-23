<script context="module">
    export function extractFilter(field, jsonRpcFilter) {
        if (jsonRpcFilter[field] !== undefined) {
            return jsonRpcFilter[field]['$in'][0]
        }
        return ''
    }
</script>