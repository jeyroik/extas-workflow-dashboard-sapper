<script context="module">
	export function preload({ params, query }) {
		let jsonRpcFilter = {};

		if (query && Object.prototype.hasOwnProperty.call(query, 'filter')) {
			jsonRpcFilter = JSON.parse(query['filter'])
		}
		return this.fetch('process.JSON_RPC__ENDPOINT', {
			method: 'POST',
			body: JSON.stringify({
				method: "workflow.state.index",
				params: {

					"expand": ["state.transitions", "schema"]
				}
			})
		}).then(r => r.json()).then(entities => {
			entities = entities.result.items;
			return { entities, jsonRpcFilter };
		});
	}
</script>

<svelte:head>
	<title>Состояния</title>
</svelte:head>

<script>
	import { save, deleteEntity, getQueryFilter } from '../components/api.svelte'
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
			"field": "schema",
			"sub": "title",
			"value": ""
		},
		{
			"empty": true
		},
		{
			"empty": true
		}
	]
</script>

<h2>Состояния - именованные объекты, описывающие текущий статус сущности (см. сущности).</h2>

<Create entity="states" text="Создать состояние"/>

<table>
	<thead>
		<tr>
			<td>Название</td>
			<td>Описание</td>
			<td>Схема</td>
			<td>Переходы (из)</td>
			<td>Переходы (в)</td>
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
			<td style="width: 120px">
				<Property bind:value={item.schema.title} title={item.schema.description} editable={false}/>
			</td>
			<td>
				<a href="transitions?filter={getQueryFilter('state_from', item.name)}" title="Перейти к переходам">{item.transitions.from.length}</a>
			</td>
			<td>
				<a href="transitions?filter={getQueryFilter('state_to', item.name)}" title="Перейти к переходам">{item.transitions.to.length}</a>
			</td>
			<td style="width: 100px">
				<button class="btn btn-danger" title="Удалить состояние" on:click={deleteEntity(item, 'state', 'Состояние', item => (item.transitions.from.length > 0) || (item.transitions.to.length > 0), 'Данное состояние используется в переходах. Сначала удалите переходы.')}>
					<span class="glyphicon glyphicon-trash" aria-hidden="true"></span>
				</button>

				<button class="btn btn-primary" title="Сохранить изменения для состояния" on:click={save(item, 'state', 'Состояние')} value="">
					<span class="glyphicon glyphicon-floppy-disk" aria-hidden="true"></span>
				</button>
			</td>
		</tr>
	{/each}
	</tbody>
</table>