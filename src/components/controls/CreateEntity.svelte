<script>
    export let entity
    export let text = 'Create ' + entity
</script>

<div class="row">
    <div class="col-md-12">
        <a class="btn btn-primary" href="/{entity}/new">{text}</a>
    </div>
</div>
