<script context="module">
    import { fabric } from "fabric"

    let onGroupOver
    let onGroupOut
    let onGroupMoving

    export function updateStateXY(x, y) {
        if (x+350 >= window.innerWidth*0.6) {
            x = 10
            y += 100
        } else {
            x += 250
        }

        return {x: x, y: y}
    }

    function makeStateRect(text) {
        let c = new fabric.Rect({
            strokeWidth: 1,
            width: text.width+8,
            height: text.height+8,
            strokeLineJoin: 'round',
            rx: 4,
            fill: '#fff',
            stroke: '#666',
            name: 'state'
        });
        let iconNew = 'M11 13a5 5 0 1 0-4.975-5.5H4A1.5 1.5 0 0 0 2.5 6h-1A1.5 1.5 0 0 0 0 7.5v1A1.5 1.5 0 0 0 1.5 10h1A1.5 1.5 0 0 0 4 8.5h2.025A5 5 0 0 0 11 13zm.5-7.5a.5.5 0 0 0-1 0v2h-2a.5.5 0 0 0 0 1h2v2a.5.5 0 0 0 1 0v-2h2a.5.5 0 0 0 0-1h-2v-2z'
        c.hasControls = c.hasBorders = false;

        return c;
    }

    export function makeStateGroup(state, x , y, groupOver, groupOut, groupMoving) {
        onGroupOver = groupOver
        onGroupOut = groupOut
        onGroupMoving = groupMoving

        let text = new fabric.Text(state.title, {
            fontSize: 20,
            selectable: false,
            left: 5,
            top: 5,
            opacity: 1,
            sourceOpacity: 1
        })

        let rect = makeStateRect(text)

        let group = new fabric.Group([rect, text], {
            selectable: true,
            hasControls: false,
            hasBorders: false,
            left: x,
            top: y,
            name: 'state ' + state.name + ' group',
            stateTitle: state.title,
            stateName: state.name,
            stateDescription: state.description,
            linesFrom: [],
            linesTo: [],
            wTransitions: [],
            allowClearTransitions: true,
            colorizeTransitions: () => {
                let lines = []
                lines = group.linesFrom
                lines.forEach((line, i) => {
                    let start = line.lineStart
                    let end = line.lineEnd
                    start.stroke = 'blue'
                    start.opacity = 1
                    start.set('dirty', true)

                    end.stroke = 'blue'
                    end.opacity = 1
                    end.set('dirty', true)
                })

                lines = group.linesTo
                lines.forEach((line, i) => {
                    let start = line.lineStart
                    let end = line.lineEnd

                    start.stroke = 'green'
                    start.opacity = 1
                    start.set('dirty', true)

                    end.stroke = 'green'
                    end.opacity = 1
                    end.set('dirty', true)
                })
            },
            clearTransitions: () => {
                let lines = []
                lines = group.linesFrom
                lines.forEach((line, i) => {
                    let start = line.lineStart
                    let end = line.lineEnd

                    start.stroke = line.sourceColor
                    start.opacity = line.sourceOpacity
                    start.set('dirty', true)

                    end.stroke = line.sourceColor
                    end.opacity = line.sourceOpacity
                    end.set('dirty', true)
                })

                lines = group.linesTo
                lines.forEach((line, i) => {
                    let start = line.lineStart
                    let end = line.lineEnd

                    start.stroke = line.sourceColor
                    start.opacity = line.sourceOpacity
                    start.set('dirty', true)

                    end.stroke = line.sourceColor
                    end.opacity = line.sourceOpacity
                    end.set('dirty', true)
                })
            }
        })

        setStateGroupMethods(group)

        return setStateGroupEvents(canvas, group)
    }

    function setStateGroupMethods(group) {
        group.getState = () => group.getObjects()[0]
        group.getText = () => group.getObjects()[1]
    }

    function setStateGroupEvents(canvas, group) {
        group.on('mouseover', function() {
            group.colorizeTransitions()
            onGroupOver(group)
        })
        group.on('mouseout', function (){
            if (group.allowClearTransitions) {
                group.clearTransitions()
            }
            onGroupOut(group)
        })
        group.on('moving', function(){
            let lines = []

            lines = group.linesFrom
            lines.forEach((line, i) => {
                let start = line.lineStart
                start.set({'x1': group.getCenterPoint().x, 'y1': group.getCenterPoint().y})
            })

            lines = group.linesTo
            lines.forEach((line, i) => {
                let end = line.lineEnd
                end.set({'x2': group.getCenterPoint().x, 'y2': group.getCenterPoint().y})
            })

            onGroupMoving(group)
        })

        return group
    }
</script>