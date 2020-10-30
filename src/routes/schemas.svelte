<script context="module">
    export function preload({ params, query }) {
        let jsonRpcFilter = {};

        if (query && Object.prototype.hasOwnProperty.call(query, 'filter')) {
            jsonRpcFilter = JSON.parse(query['filter'])
        }

        return this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.schema.index",
                params: {
                    expand:["schema.states", "schema.transitions"]
                }
            })
        }).then(r => r.json()).then(entities => {
            entities = entities.result.items;
            return { entities, jsonRpcFilter };
        });
    }
</script>

<svelte:head>
    <title>Схемы</title>
</svelte:head>

<h2>Схемы - именованные объекты, описывающие бизнес-процесс.</h2>

<script>
    import Create from '../components/controls/CreateEntity.svelte'
    import Filters from '../components/controls/Filters.svelte'
    import { save, deleteEntity, getQueryFilter } from '../components/api.svelte'
    import { extractFilter } from '../components/utils.svelte'
    import Property from '../components/inputs/EntityProperty.svelte'

    export let entities, jsonRpcFilter;

    let filters  = [
        {
            "field": "name",
            "sub": null,
            "value": extractFilter('name', jsonRpcFilter)
        },
        {
            "field": "title",
            "sub": null,
            "value": extractFilter('title', jsonRpcFilter)
        },
        {
            "field": "description",
            "sub": null,
            "value": extractFilter('description', jsonRpcFilter)
        }
    ]

    function afterDelete(item) {
        entities = entities.filter(current => current.name != item.name)
    }
</script>

<Create entity="schemas" text="Создать схему"/>

<table>
    <thead>
        <tr>
            <td>Имя</td>
            <td>Название</td>
            <td>Описание</td>
            <td>Действие</td>
        </tr>
        <Filters bind:filters={filters} bind:items={entities}/>
    </thead>
    <tbody>
    {#each entities as item}
        <tr>
            <td title="{item.name}">
                <Property bind:value={item.name}/>
            </td>
            <td title="{item.title}">
                <Property bind:value={item.title}/>
            </td>
            <td title="{item.description}">
                <Property bind:value={item.description}/>
            </td>
            <td style="min-width: 200px">
                <button title="Удалить схему" class="btn btn-danger" type="button" on:click={deleteEntity(item, 'schema', 'Схема', e => false, '', afterDelete)}>
                    <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-trash" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                        <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
                        <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4L4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
                    </svg>
                </button>
                <button class="btn btn-primary" title="Сохранить изменения" on:click={save(item, 'schema', 'Схема')} value="">
                    <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-check-circle" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd" d="M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
                        <path fill-rule="evenodd" d="M10.97 4.97a.75.75 0 0 1 1.071 1.05l-3.992 4.99a.75.75 0 0 1-1.08.02L4.324 8.384a.75.75 0 1 1 1.06-1.06l2.094 2.093 3.473-4.425a.236.236 0 0 1 .02-.022z"/>
                    </svg>
                </button>
                <a class="btn btn-primary" href="/schemas/view?name={item.name}" title="Настройки">
                    <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-gear-fill" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd" d="M9.405 1.05c-.413-1.4-2.397-1.4-2.81 0l-.1.34a1.464 1.464 0 0 1-2.105.872l-.31-.17c-1.283-.698-2.686.705-1.987 1.987l.169.311c.446.82.023 1.841-.872 2.105l-.34.1c-1.4.413-1.4 2.397 0 2.81l.34.1a1.464 1.464 0 0 1 .872 2.105l-.17.31c-.698 1.283.705 2.686 1.987 1.987l.311-.169a1.464 1.464 0 0 1 2.105.872l.1.34c.413 1.4 2.397 1.4 2.81 0l.1-.34a1.464 1.464 0 0 1 2.105-.872l.31.17c1.283.698 2.686-.705 1.987-1.987l-.169-.311a1.464 1.464 0 0 1 .872-2.105l.34-.1c1.4-.413 1.4-2.397 0-2.81l-.34-.1a1.464 1.464 0 0 1-.872-2.105l.17-.31c.698-1.283-.705-2.686-1.987-1.987l-.311.169a1.464 1.464 0 0 1-2.105-.872l-.1-.34zM8 10.93a2.929 2.929 0 1 0 0-5.86 2.929 2.929 0 0 0 0 5.858z"/>
                    </svg>
                </a>
            </td>
        </tr>
    {/each}
    </tbody>
</table>