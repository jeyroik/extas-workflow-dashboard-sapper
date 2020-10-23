<script context="module">
    export function preload({ params, query }) {
        let jsonRpcFilter = {};
        if (query && Object.prototype.hasOwnProperty.call(query, 'filter')) {
            jsonRpcFilter = JSON.parse(query['filter'])
        }
        return this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.transition.index",
                params: {
                    expand:[
                        "transition.state_from",
                        "transition.state_to",
                        "schema",
                        "transition.dispatchers"
                    ],
                    context: {},
                    entity: {},
                    filter: jsonRpcFilter,
                    conditions: false
                }
            })
        }).then(r => r.json()).then(entities => {
            entities = entities.result.items;
            return { entities, jsonRpcFilter };
        });
    }
</script>

<svelte:head>
    <title>Переходы</title>
</svelte:head>

<script>
    import { save, getQueryFilter } from '../components/api.svelte';
    import { extractFilter } from '../components/utils.svelte'
    import Filters from '../components/controls/Filters.svelte'
    import Create from '../components/controls/CreateEntity.svelte'
    import Property from '../components/inputs/EntityProperty.svelte'

    export let entities
    export let jsonRpcFilter

    let filters  = [
        {
            "field": "title",
            "sub": null,
            "value": extractFilter('title', jsonRpcFilter)
        },
        {
            "field": "description",
            "sub": null,
            "value": extractFilter('description', jsonRpcFilter)
        },
        {
            "field": "state_from",
            "sub": "title",
            "value": ""
        },
        {
            "field": "state_to",
            "sub": "title",
            "value": ""
        },
        {
            "field": "schema",
            "sub": "title",
            "value": ""
        }
    ]
</script>

<h3>Переходы - именованные объекты, описывающие изменение состояния сущности.</h3>

<Create entity="transitions" text="Создать переход"/>

<table>
    <thead>
        <tr>
            <td>Название</td>
            <td>Описание</td>
            <td>Из</td>
            <td>В</td>
            <td>Схема</td>
            <td>Действие</td>
        </tr>
        <Filters bind:filters={filters} bind:items={entities}/>
    </thead>
    <tbody>
    {#each entities as item}
        <tr>
            <td title="{item.name}">
                <Property bind:value={item.title}/>
            </td>
            <td style="width:250px; padding: 5px">
                <Property bind:value={item.description}/>
            </td>
            <td>
                <a href="states?filter={getQueryFilter('name', item.state_from.name)}" title="Перейти к состоянию">
                    {item.state_from.title}
                </a>
            </td>
            <td>
                <a href="states?filter={getQueryFilter('name', item.state_to.name)}" title="Перейти к состоянию">
                    {item.state_to.title}
                </a>
            </td>
            <td style="width: 120px">
                <Property bind:value={item.schema.title} title={item.schema.description} editable={false}/>
            </td>
            <td style="width: 100px">
                <button class="btn btn-danger" title="Удалить переход">
                    <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>
                </button>

                <button class="btn btn-primary" title="Сохранить изменения для перехода" on:click={save(item, 'transition', 'Переход')}>
                    <span class="glyphicon glyphicon-floppy-disk" aria-hidden="true"></span>
                </button>
            </td>
        </tr>
    {/each}
    </tbody>
</table>

<style>
    thead{
        border-bottom: 1px solid grey;
    }
</style>