<script context="module">
    export function preload({ params, query }) {
        return this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({method: "workflow.entity.index"})
        }).then(r => r.json()).then(entities => {
            entities = entities.result.items;
            return { entities };
        });
    }
</script>

<svelte:head>
    <title>Сущности</title>
</svelte:head>

<h2>Сущности - именованные объекты, описывающие сущности, для которых определяется бизнес-процесс. В рамках одной схемы может использоваться только одна сущность.</h2>

<script>
    import { Tabs, TabList, TabPanel, Tab } from '../components/tabs.js';
    export let entities;
</script>

<table>
    <thead>
    <tr>
        <td>Название</td>
        <td>Описание</td>
        <td>Действие</td>
    </tr>
    </thead>
    <tbody>
    {#each entities as item}
        <tr>
            <td title="{item.name}">{item.title}</td>
            <td>{item.description}</td>
            <td>
                <button title="Удалить переход">Удалить</button>
                <button title="Изменить переход">Изменить</button>
            </td>
        </tr>
    {/each}
    </tbody>
</table>