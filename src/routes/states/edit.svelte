<script context="module">
    export async function preload({ params, query }) {
        const statesResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.state.index",
                params: {
                    expand:["sample.states"],
                    filter: {name: {"$in":[query.name]}}
                }
            })
        })
        const samplesResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.state.sample.index",
                params: {
                    expand:["sample.states"]
                }
            })
        })

        const schemasResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.schema.index"
            })
        });

        const schemas = await schemasResult.json().then(r => r.result.items);
        const samples = await samplesResult.json().then(r => r.result.items);
        const states = await statesResult.json().then(r => r.result.items);
        const state = states.pop()

        return { state, schemas, samples, query };
    }
</script>

<script>
    import { jsonRpc, save } from '../../components/api.svelte';
    import { goto } from '@sapper/app'
    export let state, samples, schemas, query;

    $: samplesForPrint = samples
    $: schemasForPrint = schemas

    function afterSave(item) {
        let link = '/states/?filter={"title":{"$in":["'+item.title+'"]}}'
        if (typeof query.back_to_url != 'undefined') {
            console.log('bask to url')
            link = query.back_to_url + '&created=' + item.name// DANGER!!! CHECK LINK FOR THE SAME DOMAIN!!!
        }
        goto(link)
    }
</script>

<svelte:head>
    <title>Состояния - Новое</title>
</svelte:head>

<h2>Редактирование состояния</h2>

<div class="row">
    <div class="col-md-12">
        <div class="form-group">
            <label for="name">Имя</label>
            <input value={state.name} readonly id="name" type="text" class="form-control form-control-sm">
        </div>
        <div class="form-group">
            <label for="title">Название</label>
            <input bind:value={state.title} id="title" type="text" class="form-control form-control-sm">
        </div>
        <div class="form-group">
            <label for="description">Описание</label>
            <input bind:value={state.description} id="description" type="text" class="form-control form-control-sm">
        </div>
        <div class="form-group">
            <label for="sample_name">Шаблон</label>
            <select bind:value={state.sample_name} id="sample_name" class="form-control form-control-sm">
                <option value="">Выберите шаблон</option>
                {#each samplesForPrint as item}
                    <option value="{item.name}" title="{item.description}">{item.title}</option>
                {/each}
            </select>
        </div>
        <div class="form-group">
            <label for="schema_name">Схема</label>
            <select required bind:value={state.schema_name} id="schema_name" class="form-control form-control-sm">
                <option value="">Выберите схему</option>
                {#each schemasForPrint as item}
                    <option value="{item.name}" title="{item.description}">{item.title}</option>
                {/each}
            </select>
        </div>
        <div class="form-group">
            <button on:click={save(state, 'state', 'Состояние', afterSave)} class="btn btn-primary">Сохранить</button>
        </div>
    </div>
</div>
