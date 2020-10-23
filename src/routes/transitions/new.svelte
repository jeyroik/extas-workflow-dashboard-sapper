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

        const schemas = await schemasResult.json().then(r => r.result.items);
        const samples = await samplesResult.json().then(r => r.result.items);

        return { schemas, samples };
    }
</script>

<script>
    import { jsonRpc } from '../../components/api.svelte';
    import { goto } from '@sapper/app'
    export let samples, schemas;

    $: samplesForPrint = samples
    $: schemasForPrint = schemas

    let state = {
        name: '',
        title: '',
        description: '',
        sample_name: '',
        schema_name: ''
    };

    async function isStateExist(){
        jsonRpc(
            {
                method: "workflow.transition.index",
                params: {
                    context: {},
                    entity: {},
                    filter: {
                        name: {
                            in: [state.name]
                        }
                    }
                }
            },
            (result) => {
                if (result.total == 1) {
                    M.toast({
                        html: 'Переход с именем "' + state.name + '" уже существует',
                        classes: 'red'
                    });
                }
            }
        );
    }

    async function create() {
        jsonRpc(
            {
                method: "workflow.transition.create",
                params: {
                    data: state
                }
            },
            () => {
                goto('/transitions/?filter={"title":{"$in":["'+state.title+'"]}}')
                M.toast({
                    html: 'Переход "' + state.title + '" создан',
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
            <label for="name">Имя</label>
            <input autofocus on:blur={isStateExist} bind:value={state.name} id="name" type="text" class="form-control form-control-sm">
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
            <select on:change={fillInWithSample} bind:value={state.sample_name} id="sample_name" class="form-control form-control-sm">
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
            <button on:click={create} class="btn btn-primary">Создать</button>
        </div>
    </div>
</div>
