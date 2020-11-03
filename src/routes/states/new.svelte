<script context="module">
    export async function preload({ params, query }) {
        const samplesResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.state.sample.index",
                params: {
                    expand:["sample.states"]
                }
            })
        });

        const schemasResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.schema.index"
            })
        });

        const schemas = await schemasResult.json().then(r => r.result.items);
        const samples = await samplesResult.json().then(r => r.result.items);

        return { schemas, samples, query };
    }
</script>

<script>
    import { jsonRpc } from '../../components/api.svelte';
    import { goto } from '@sapper/app'
    import { v4 } from 'uuid'
    export let samples, schemas, query;

    $: samplesForPrint = samples
    $: schemasForPrint = schemas

    let state = {
        name: v4(),
        title: '',
        description: '',
        sample_name: '',
        schema_name: ''
    };

    function fillInEntityWithQuery(query, entity) {
        for (const [key, value] of Object.entries(entity)) {
            if (typeof query[key] != 'undefined') {
                entity[key]=query[key]
            }
        }
    }

    fillInEntityWithQuery(query, state)

    async function create() {
        jsonRpc(
            {
                method: "workflow.state.create",
                params: {
                    data: state
                }
            },
            () => {
                console.log(query)
                let link = '/states'
                if (typeof query.back_to_url != 'undefined') {
                    console.log('bask to url')
                    link = query.back_to_url + '&created=' + state.name// DANGER!!! CHECK LINK FOR THE SAME DOMAIN!!!
                }
                goto(link)
                M.toast({
                    html: 'Состояние "' + state.title + '" создано',
                    classes: 'red'
                });
            }
        );
    }
</script>

<svelte:head>
    <title>Состояния - Новое</title>
</svelte:head>

<h2>Создание состояния</h2>

<div class="row">
    <div class="col-md-12">
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
                    <option value="none">Без шаблона</option>
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
            <button on:click={create} class="btn btn-primary">Создать</button>
        </div>
    </div>
</div>
