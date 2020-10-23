<script context="module">
    export function preload({ params, query }) {
        return this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.state.sample.index",
                params: {
                    expand:["sample.states"]
                }
            })
        }).then(r => r.json()).then(entities => {
            entities = entities.result.items;
            return { entities };
        });
    }
</script>

<svelte:head>
    <title>Шаблоны состояний</title>
</svelte:head>

<h2>Шаблоны состояний - именованные объекты, использующиеся для создания новых состояний.</h2>

<script>
    import { Tabs, TabList, TabPanel, Tab } from '../components/tabs.js';
    import { save, getQueryFilter } from '../components/api.svelte'

    export let entities;

    $: entitiesForPrint = entities

    function filter(e) {
        entitiesForPrint = entitiesForPrint.filterByField(e, entities)
    }

    function addRow() {
        states.unshift({ tmp: true, name: '', title: '', description: ''});
        states = states
    }
</script>

<table>
    <thead>
        <tr>
            <td>Название</td>
            <td>Описание</td>
            <td>Состояния</td>
            <td>Действие</td>
        </tr>
        <tr>
            <td>
                <input type="text" on:input={filter} data-field="title">
            </td>
            <td>
                <input type="text" on:input={filter} data-field="description">
            </td>
            <td>
                <a href="/states_samples" title="Очистить фильтр">
                    <span class="glyphicon glyphicon-ban-circle" aria-hidden="true"></span>
                </a>
            </td>
        </tr>
    </thead>
    <tbody>
    {#each entitiesForPrint as item}
        <tr>
            <td title="{item.name}">
                <input bind:value={item.title} type="text" class="silent-input-text">
            </td>
            <td style="width:250px; padding: 5px">
                <input bind:value={item.description} type="text" class="silent-input-text">
            </td>
            <td><a href="/states?filter={getQueryFilter('sample_name', item.name)}" title="Перейти к состояниям">{item.states.length}</a></td>
            <td style="width: 100px">
                <button class="btn btn-danger" title="Удалить шаблон">
                    <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>
                </button>

                <button class="btn btn-primary" title="Сохранить изменения" on:click={save(item, 'state.sample', 'Шаблон состояния')}>
                    <span class="glyphicon glyphicon-floppy-disk" aria-hidden="true"></span>
                </button>
            </td>
        </tr>
    {/each}
    </tbody>
</table>