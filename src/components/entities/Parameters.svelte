<script>
    import Parameter from './Parameter.svelte'
    import { v4 } from 'uuid'

    export let parameters

    function addParameter() {
        let p = {
            id: v4(),
            name: '',
            title: '',
            description: ''
        }
        parameters.push(p)
        parameters = parameters
    }

    function rmParameter (e) {
        parameters = parameters.filter(p => p.id != e.detail.parameter.id)
    }
</script>

<div class="form-group">
    <div class="card">
        <div class="card-header">Параметры</div>
        <div class="card-body">
            <ul class="list-group">
                {#each parameters as p}
                    <Parameter bind:p={p} on:remove-parameter={rmParameter}/>
                {/each}
            </ul>
        </div>
        <div class="card-footer">
            <div class="form-group">
                <button class="btn btn-info" title="Добавить параметр" on:click={addParameter}>
                    <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-plus-circle" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd" d="M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
                        <path fill-rule="evenodd" d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"/>
                    </svg>
                </button>
            </div>
        </div>
    </div>
</div>