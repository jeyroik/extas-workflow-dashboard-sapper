<script context="module">
    export async function preload({ params, query }) {
        const samplesResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.transition.sample.index",
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

        const statesResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.state.index"
            })
        });

        const schemas = await schemasResult.json().then(r => r.result.items);
        const samples = await samplesResult.json().then(r => r.result.items);
        const states = await statesResult.json().then(r => r.result.items);

        return { schemas, samples, states, query };
    }
</script>

<script>
    import { jsonRpc } from '../../components/api.svelte';
    import { goto } from '@sapper/app'
    import { v4 } from 'uuid'
    export let samples, schemas, states, query;

    $: samplesForPrint = samples
    $: schemasForPrint = schemas
    $: statesForPrint = states

    let entity = {
        name: v4(),
        title: '',
        description: '',
        sample_name: '',
        state_from: '',
        state_to: '',
        schema_name: ''
    };

    function fillInEntityWithQuery(query, entity) {
        for (const [key, value] of Object.entries(entity)) {
            if (typeof query[key] != 'undefined') {
                entity[key]=query[key]
            }
        }
    }

    fillInEntityWithQuery(query, entity)

    function getStateByName(name, list) {
        let state = null
        list.forEach(s => {
            if (s.name == name) {
                state = s
            }
        })

        return state
    }

    if (entity.state_from !== '') {
        entity.name = 'from_'+entity.state_from.replace(' ', '_')
        entity.description = 'Из ' + getStateByName(entity.state_from, states).title
    }

    if (entity.state_to !== '') {
        entity.name += '__to_'+entity.state_to.replace(' ', '_')
        entity.description += ' в ' + getStateByName(entity.state_to, states).title
    }

    async function create() {
        jsonRpc(
            {
                method: "workflow.transition.create",
                params: {
                    data: entity
                }
            },
            () => {
                let link = '/transitions'
                if (typeof query.back_to_url != 'undefined') {
                    link = query.back_to_url + '&created=' + entity.name// DANGER!!! CHECK LINK FOR THE SAME DOMAIN!!!
                }
                goto(link)
                M.toast({
                    html: 'Переход "' + entity.title + '" создан',
                    classes: 'red'
                });
            }
        );
    }

    function fillInWithSample(e) {
        samples.forEach(item => {
            if (item.name === e.target.value) {
                console.log(item)
                state.title = item.title
                state.description = item.description
            }
        })
        console.log(state)
    }
</script>

<svelte:head>
    <title>Переходы - Новый</title>
</svelte:head>

<h2>Создание перехода</h2>

<div class="row">
    <div class="col-md-12">
        <div class="form-group">
            <label for="title">Название</label>
            <input bind:value={entity.title} id="title" type="text" class="form-control form-control-sm">
        </div>
        <div class="form-group">
            <label for="description">Описание</label>
            <input bind:value={entity.description} id="description" type="text" class="form-control form-control-sm">
        </div>
        <div class="form-group">
            <label for="sample_name">Шаблон</label>
            <select on:change={fillInWithSample} bind:value={entity.sample_name} id="sample_name" class="form-control form-control-sm">
                    <option value="">Выберите шаблон</option>
                    <option value="none">Без шаблона</option>
                {#each samplesForPrint as item}
                    <option value="{item.name}" title="{item.description}">{item.title}</option>
                {/each}
            </select>
        </div>
        <div class="form-group">
            <label for="state_from">Из состояния</label>
            <select required bind:value={entity.state_from} id="state_from" class="form-control form-control-sm">
                <option value="">Выберите начальное состояние</option>
                {#each statesForPrint as item}
                    <option value="{item.name}" title="{item.description}">{item.title}</option>
                {/each}
            </select>
        </div>
        <div class="form-group">
            <label for="state_to">В состояние</label>
            <select required bind:value={entity.state_to} id="state_to" class="form-control form-control-sm">
                <option value="">Выберите конечное состояние</option>
                {#each statesForPrint as item}
                    <option value="{item.name}" title="{item.description}">{item.title}</option>
                {/each}
            </select>
        </div>
        <div class="form-group">
            <label for="schema_name">Схема</label>
            <select required bind:value={entity.schema_name} id="schema_name" class="form-control form-control-sm">
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
