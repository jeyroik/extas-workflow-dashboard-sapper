<script context="module">
    export async function jsonRpc(data, success) {
        console.log('endpoint: ' + `process.JSON_RPC__ENDPOINT`)
        let response = await fetch(`process.JSON_RPC__ENDPOINT`, {
            method: 'POST',
            body: JSON.stringify(data)
        }).then(r => r.json());

        let error = response.error;

        if (error) {
            M.toast({html: 'Ошибка: ' + error.message, classes: 'red'});
            return false;
        } else {
            success && success(response.result);
        }

        return response;
    }

    export async function create(entity, entityPath, entityTitle, after) {
        jsonRpc(
            {
                method: "workflow."+entityPath+".create",
                params: {
                    data: entity
                }
            },
            () => {
                M.toast({
                    html: entityTitle + ' "' + entity.title + '" создан[а]',
                    classes: 'red'
                });
                after(entity)
            }
        );
    }

    export async function save(entity, entityName, entityTitle, afterSave) {
        jsonRpc(
            {
                method: 'workflow.'+entityName+'.update',
                params: {
                    data: {
                        name: entity.name,
                        title: entity.title,
                        description: entity.description,
                    }
                }
            },
            function (result) {
                M.toast({
                    html: entityTitle + ' "' + result.pop().title + '" сохранен[а]',
                    classes: 'green'
                });
                if (typeof afterSave != 'undefined') {
                    afterSave(entity)
                }
            }
        );
    }

    export async function saveEntity(entity, afterSave) {
        jsonRpc(
            {
                method: 'workflow.transition.dispatcher.update',
                params: {
                    data: entity
                }
            },
            function (result) {
                M.toast({
                    html: 'Обработчик "' + result.pop().title + '" сохранен[а]',
                    classes: 'green'
                });
                if (typeof afterSave != 'undefined') {
                    afterSave(entity)
                }
            }
        );
    }

    export async function del(entity, entityName, entityTitle) {
        jsonRpc(
            {
                method: 'workflow.'+entityName+'.delete',
                params: {
                    data: {
                        name: entity.name,
                        title: entity.title,
                        description: entity.description,
                    }
                }
            },
            function (result) {
                let deleted = result['items'].pop()
                M.toast({
                    html: entityTitle + ' "' + deleted.title + '" удален[а]',
                    classes: 'green'
                });
            }
        );
    }

    export function deleteEntity(item, title, desc, check, checkMsg, afterDelete){
        if (check(item)) {
            M.toast({
                html: checkMsg,
                classes: 'green'
            });
        } else {
            del(item, title, desc)
            afterDelete(item)
        }
    }

    export function getQueryFilter(field, value)
    {
        if (field) {
            return '{"' + field + '":{"$in":["' + value + '"]}}'
        }

        return '{}';
    }
</script>
