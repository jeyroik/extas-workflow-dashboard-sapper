<script context="module">
    export function preload({ params, query }) {
        return this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({method: "workflow.schema.sample.index"})
        }).then(r => r.json()).then(entities => {
            entities = entities.result.items;
            return { entities };
        });
    }
</script>

<svelte:head>
    <title>Шаблоны схем</title>
</svelte:head>

<h2>Шаблоны схем - именованные объекты, использующиеся для создания новых схем.</h2>

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
            <td>{item.title}</td>
            <td>{item.description}</td>
            <td>
                <button title="Создать переход">Создать</button>
            </td>
        </tr>
    {/each}
    </tbody>
</table>