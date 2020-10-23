<script context="module">
    export function preload({ params, query }) {
        return this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.schema.index",
                params: {
                    filter: {
                        name: {'$in':[query.name]}
                    },
                    expand:["schema.states", "schema.transitions"]
                }
            })
        }).then(r => r.json()).then(entities => {
            let schema = entities.result.items.pop();
            return { schema };
        });
    }
</script>

<svelte:head>
    <title>Схема - {schema.title} - {schema.description}</title>
</svelte:head>

<script>
    import { fabric } from "fabric"
    import { onMount, onDestroy } from 'svelte'

    export let schema
    let stateCoords = {}

    function makeCircle() {
        let c = new fabric.Circle({
            strokeWidth: 5,
            radius: 12,
            fill: '#fff',
            stroke: '#666',
            name: 'state'
        });
        c.hasControls = c.hasBorders = false;

        return c;
    }

    function makeLine(coords) {
        return new fabric.Line(coords, {
            fill: '',
            stroke: 'gray',
            opacity: 0.2,
            strokeWidth: 5,
            selectable: true,
            evented: true,
            name: 'line start ' + Math.random(),
            sourceColor: 'gray',
            sourceOpacity: 0.2
        })
    }

    let canvas;

    onDestroy(() => {
        canvas && canvas.dispose()
    })

    onMount(() => {
        canvas = new fabric.Canvas('canvas', {selection: false});
        let states = schema.states
        let x = 120
        let y = 40
        let statesCircles = {}
        states.forEach(state => {
            let text = new fabric.Text(state.title, {
                fontSize: 20,
                selectable: false,
                left: 25,
                top: 25,
                opacity: 1,
                sourceOpacity: 1
            })

            let circle = makeCircle()
            let group = new fabric.Group([circle, text], {
                selectable: true,
                hasControls: false,
                hasBorders: false,
                left: x,
                top: y,
                name: 'state ' + state.name + ' group',
                stateTitle: state.title,
                linesFrom: [],
                linesTo: [],
                wTransitions: []
            })

            group.on('mouseover', function() {
                let lines = []

                lines = group.linesFrom
                lines.forEach((line, i) => {
                    line.stroke = 'blue'
                    line.opacity = 1
                    line.set('dirty', true)
                })

                lines = group.linesTo
                lines.forEach((line, i) => {
                    line.stroke = 'green'
                    line.opacity = 1
                    line.set('dirty', true)
                })

                transitionsNames = group.wTransitions

                canvas.renderAll()
            })
            group.on('mouseout', function (){
                let lines = []

                lines = group.linesFrom
                lines.forEach((line, i) => {
                    line.stroke = line.sourceColor
                    line.opacity = line.sourceOpacity
                    line.set('dirty', true)
                })

                lines = group.linesTo
                lines.forEach((line, i) => {
                    line.stroke = line.sourceColor
                    line.opacity = line.sourceOpacity
                    line.set('dirty', true)
                })

                transitionsNames = []

                canvas.renderAll()
            })
            group.on('moving', function(){
                let lines = []

                lines = group.linesFrom
                lines.forEach((line, i) => {
                    line.set({'x1': group.left+12, 'y1': group.top+12})
                })

                lines = group.linesTo
                lines.forEach((line, i) => {
                    line.set({'x2': group.left+12, 'y2': group.top+12})
                })

                canvas.renderAll()
            })

            stateCoords[state.name] = {x: x, y: y, width: text.width + 5}
            statesCircles[state.name] = group

            if (x+250 >= 600) {
                x = 10
                y += 60
            } else {
                x += 250
            }

        })

        let transitions = schema.transitions;

        transitions.forEach(t => {
            let coords = [
                stateCoords[t.state_from].x+12,
                stateCoords[t.state_from].y+12,
                stateCoords[t.state_to].x+12,
                stateCoords[t.state_to].y+12
            ]
            let line = makeLine(coords)

            let tFakeFrom = {
                title: t.title,
                state_from: statesCircles[t.state_from].stateTitle,
                state_to: statesCircles[t.state_to].stateTitle,
                dir: '->'
            }

            let tFakeTo = {
                title: t.title,
                state_from: statesCircles[t.state_to].stateTitle,
                state_to: statesCircles[t.state_from].stateTitle,
                dir: '<-'
            }

            statesCircles[t.state_from].linesFrom.push(line)
            statesCircles[t.state_from].wTransitions.push(tFakeFrom)

            statesCircles[t.state_to].linesTo.push(line)
            statesCircles[t.state_to].wTransitions.push(tFakeTo)

            canvas.add(line)
        })

        for (var [key,value] of Object.entries(statesCircles)) {
            canvas.add(value)
        }
    })

    let transitionsNames = []
    let dirs = {
        '->': '<span style="color: blue" class="glyphicon glyphicon-arrow-right" aria-hidden="true"></span>',
        '<-': '<span style="color: green" class="glyphicon glyphicon-arrow-left" aria-hidden="true"></span>'
    }
</script>

<h2>Схема {schema.title} - {schema.description}</h2>

<canvas id="canvas" width="650" height="650"></canvas>
<div class="row tlist">
    <div class="col-md-12">
        <ul>
            {#each transitionsNames as transition}
                <li>{transition.title} : {transition.state_from} {@html dirs[transition.dir]} {transition.state_to}</li>
            {/each}
        </ul>
    </div>
</div>

<style>
    .tlist{
        position: absolute;
        left: 90%;
        top: 20%;
        width: 300px;
    }
</style>