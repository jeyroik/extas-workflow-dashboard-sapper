<script context="module">
    export function preload({ params, query }) {
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
            return { entities };
        });
    }
</script>

<svelte:head>
    <title>Схемы</title>
</svelte:head>

<h2>Схемы - именованные объекты, описывающие бизнес-процесс.</h2>

<script>
    import { onMount } from 'svelte'
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
                <button title="Удалить схему">Удалить</button>
                <a href="/schemas/view?name={item.name}" title="Настройки">
                    <span class="glyphicon glyphicon-cog" aria-hidden="true"></span>
                </a>
            </td>
        </tr>
    {/each}
    </tbody>
</table>