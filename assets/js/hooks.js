import Mde from 'easymde';

const Hooks = {
    Flash: {
        mounted() {
            this.el.addEventListener('click', () => {
                this.closeFlash()
            });
        },
        closeFlash() {
            this.pushEvent("lv:clear-flash")
        }
    },
    Lang: {
        mounted() {
            this.el.addEventListener('change', (e) => {
                const parser = new URL(window.location);
                parser.searchParams.set('locale', e.target.value);
                window.location = parser.href;
            });
        }
    },
    ScrollOnUpdate: {
        mounted() {
            this.el.scrollIntoView();
        }
    },
    MultiSelect: {
        mounted() {
            const input = this.el.querySelector('input');
            const target = this.el.getAttribute('phx-target');
            const listName = this.el.getAttribute('data-list');

            input.addEventListener('keyup', (event) => {
                let value = event.target.value;
                if (event.key === ',') {
                    value.split(',').filter(v => v).forEach(item => {
                        const data = {
                            list: listName,
                            item: {
                                id: item,
                                title: item
                            },
                            type: 'add'
                        };
                        event.target.value = '';

                        if (!target) {
                            return this.pushEvent('multiselect', data);
                        }

                        this.pushEventTo(target, 'multiselect', data);
                    });
                }
            })
        }
    },
    Markdown: {
        mounted() {
            console.log('loaded!')
            const mde = new Mde({
                element: this.el,
                uploadImage: true,
                imageUploadFunction: (file, s, e) => {
                    console.log('file : ', file)
                }
            });


            let targetTextarea = this.getTarget(this.el.getAttribute('id'));

            mde.codemirror.on('change', function () {
                if (!targetTextarea) {
                    targetTextarea = this.getTarget(this.el.getAttribute('id'));
                }
                if (targetTextarea) {
                    targetTextarea.value = mde.value();
                }
            });
        },
        getTarget(id) {
            return document.querySelector(`textarea[data-id="target-${id}"]`);
        }
    }
}


export default Hooks;