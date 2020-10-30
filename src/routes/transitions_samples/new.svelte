<script context="module">
    export async function preload({ params, query }) {
        const samplesResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.state.sample.index",
                params: {}
            })
        });
        const states = await samplesResult.json().then(r => r.result.items);
        
        return { states };
    }
</script>
<script>
    import { jsonRpc } from '../../components/api.svelte';
    import { goto } from '@sapper/app'
    import { v4 } from 'uuid'

    export let states

    let sample = {
        name: v4(),
        title: '',
        description: '',
        state_from: '',
        state_to: ''
    };
    
    async function create() {
        jsonRpc(
            {
                method: "workflow.transition.sample.create",
                params: {
                    data: sample
                }
            },
            () => {
                let link = '/transitions_samples'
                goto(link)
                M.toast({
                    html: 'Шаблон "' + sample.title + '" создан',
                    classes: 'red'
                });
            }
        );
    }
</script>

<svelte:head>
    <title>Шаблоны переходов - Новый</title>
</svelte:head>

<h2>Создание шаблона перехода</h2>

<div class="row">
    <div class="col-md-12">
        <div class="form-group">
            <label for="title">Название</label>
            <input bind:value={sample.title} id="title" type="text" class="form-control form-control-sm">
        </div>
        <div class="form-group">
            <label for="description">Описание</label>
            <input bind:value={sample.description} id="description" type="text" class="form-control form-control-sm">
        </div>
        <div class="form-group">
            <label for="state_from">Исходное состояние</label>
            <select bind:value={sample.state_from} id="state_from" class="form-control form-control-sm">
                <option value="">Выберите шаблон состояния</option>
                {#each states as item}
                    <option value="{item.name}" title="{item.description}">{item.title}</option>
                {/each}
            </select>
        </div>
        <div class="form-group">
            <label for="state_to">Конечное состояние</label>
            <select bind:value={sample.state_to} id="state_from" class="form-control form-control-sm">
                <option value="">Выберите шаблон состояния</option>
                {#each states as item}
                    <option value="{item.name}" title="{item.description}">{item.title}</option>
                {/each}
            </select>
        </div>

        <div class="form-group">
            <button on:click={create} class="btn btn-primary">Создать</button>
        </div>
    </div>
</div>
