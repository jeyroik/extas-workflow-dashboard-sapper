<script>
	export let segment;
</script>

<style>
	nav {
		border-bottom: 1px solid rgba(255,62,0,0.1);
		font-weight: 300;
		padding: 0 1em;
	}

	ul {
		margin: 0;
		padding: 0;
	}

	/* clearfix */
	ul::after {
		content: '';
		display: block;
		clear: both;
	}

	li {
		display: block;
		float: left;
	}

	[aria-current] {
		position: relative;
		display: inline-block;
	}

	[aria-current]::after {
		position: absolute;
		content: '';
		width: calc(100% - 1em);
		height: 2px;
		background-color: rgb(255,62,0);
		display: block;
		bottom: -1px;
	}

	a {
		text-decoration: none;
		padding: 1em 0.5em;
		display: block;
	}
</style>

<nav>
	<ul>
		<li><a aria-current="{segment === undefined ? 'page' : undefined}" href=".">дашборд</a></li>
		<li><a aria-current="{segment === 'states_samples' ? 'page' : undefined}" href="states_samples">шаблоны состояний</a></li>
		<li><a aria-current="{segment === 'states' ? 'page' : undefined}" href="states">состояния</a></li>
		<li><a aria-current="{segment === 'transitions_samples' ? 'page' : undefined}" href="transitions_samples">шаблоны переходов</a></li>
		<li><a aria-current="{segment === 'transitions' ? 'page' : undefined}" href="transitions">переходы</a></li>
		<li><a aria-current="{segment === 'dispatchers_samples' ? 'page' : undefined}" href="dispatchers_samples">шаблоны обработчиков</a></li>
		<li><a aria-current="{segment === 'dispatchers' ? 'page' : undefined}" href="dispatchers">обработчики</a></li>
		<li><a aria-current="{segment === 'schemas_samples' ? 'page' : undefined}" href="schemas_samples">шаблоны схем</a></li>
		<li><a aria-current="{segment === 'schemas' ? 'page' : undefined}" href="schemas">схемы</a></li>
		<li><a aria-current="{segment === 'entities_samples' ? 'page' : undefined}" href="entities_samples">шаблоны сущностей</a></li>
		<li><a aria-current="{segment === 'entities' ? 'page' : undefined}" href="entities">сущности</a></li>
	</ul>
</nav>
