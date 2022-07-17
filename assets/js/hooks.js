import moment from 'moment';
import Litepicker from 'litepicker';

const Hooks = {
    Sidebar: {
        key: 'sidebar-minimized',
        mounted() {
            this.el.querySelectorAll('.btn__minimize').forEach(el => {
                el.addEventListener('click', () => this.toggleMinimize());
            });

            this._updateUI();
        },
        updated() {
            this._updateUI();
        },
        isMinimized() {
            return localStorage.getItem(this.key) === 'true';
        },
        toggleMinimize() {
            const newState = !this.isMinimized();
            localStorage.setItem(this.key, newState);

            this._updateUI();
            return newState;
        },
        _updateClass() {
            if (this.isMinimized()) {
                this.el.classList.add('mini');
            } else {
                this.el.classList.remove('mini');
            }
        },
        _updateBtnClass() {
            this.el.querySelectorAll('.btn__minimize').forEach(el => {
                if (this.isMinimized()) {
                    el.classList.add('active');
                } else {
                    el.classList.remove('active');
                }
            });
        },
        _updateUI() {
            this._updateClass();
            this._updateBtnClass();
        }
    },
    Flash: {
        mounted() {
            this.el.addEventListener('click', () => {
                this.closeFlash();
            });
        },
        closeFlash() {
            this.pushEvent("lv:clear-flash");
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
            const listName = this.el.dataset.list;

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
            });
        }
    },
    DateRange: {
        mounted() {
            new Litepicker({
                element: this.el,
                singleMode: false,
                tooltipText: {
                    one: 'day',
                    other: 'days'
                },
                setup: (picker) => {
                    picker.on('selected', (date1, date2) => {
                        // some action
                        const a = moment(date1.dateInstance);
                        const b = moment(date2.dateInstance);

                        this.el.innerText = `Period: ${a.format('YYYY-MM-DD')} - ${b.format('YYYY-MM-DD')}  (${b.diff(a, 'days')} days)`;

                        this.pushEvent('period', { start: date1.dateInstance, end: date2.dateInstance });
                    });
                },

            });

        }
    },
    TimeAgo: {
        date: 0,
        timer: null,
        mounted() {
            this.date = moment.utc(this.el.getAttribute('datetime'));
            this.updateTime();
        },
        destroyed() {
            clearTimeout(this.timer);
        },
        updateTime() {
            let nextUpdate = moment.utc().local().diff(this.date) / 1000;

            if (nextUpdate < 60) {
                nextUpdate = 1;
            } else if (nextUpdate < 60 * 60) {
                nextUpdate = 60;
            } else {
                nextUpdate = 60 * 60;
            }

            this.el.innerText = this.date.fromNow();
            this.timer = setTimeout(() => {
                this.updateTime();
            }, nextUpdate * 1000);
        }
    },
    ShortCut: {
        func: null,
        data: {},
        mounted() {
            this.data = {
                altKey: true,
                ctrlKey: false,
                key: this.el.dataset.key,
                targetEl: document.querySelector(this.el.dataset.targetEl),
            };

            this.el.querySelector('[key]').innerText = this.data.key;

            this.keyDown = (event) => {
                if (event.altKey == this.data.altKey &&
                    event.ctrlKey == this.data.ctrlKey &&
                    `${event.key}` == `${this.data.key}`) {
                    if (this.data.targetEl) {
                        this.data.targetEl.classList.add('shortcut__press');
                        this.data.targetEl.click();
                    }
                }
            }

            this.keyUp = (event) => {
                if (`${event.key}` == `${this.data.key}`) {
                    if (this.data.targetEl) {
                        this.data.targetEl.classList.remove('shortcut__press');
                    }
                }
            }

            document.addEventListener('keydown', this.keyDown);
            document.addEventListener('keyup', this.keyUp);
        },
        destroyed() {
            document.removeEventListener('keyup', this.keyUp);
            document.removeEventListener('keydown', this.keyDown);
        }
    },
    SearchSelect: {
        mounted() {
            this.el.querySelector(".dropdown__content").style.display = "none";
            this.hidden = true;
            this.addListeners();
        },
        updated() {
            const list = this.el.querySelector(".dropdown__content");
            if (this.hidden) {
                list.style.display = "none";
            } else {
                list.style.display = "block";
            }
            this.removeListeners();
            this.addListeners();
        },
        destroyed() {
            this.removeListeners();
        },
        addListeners() {
            const input = this.el.querySelector(".search__input");
            const toggleBtn = this.el.querySelector(".toggle__btn");
            let list = this.el.querySelector(".dropdown__content");

            this.focusEvt = input.addEventListener("focus", (evt) => {
                this.hidden = false;
                list.style.display = "block";
            });
            this.keyupEvt = input.addEventListener("keyup", (evt) => {
                this.hidden = false;
                list.style.display = "block";
                clearTimeout(this.keyupTimeout);
                this.keyupTimeout = setTimeout(() => {
                    const value = evt.target.value;
                    this.pushEventTo(this.el.getAttribute("phx-target"), "filter", value);
                }, 400);
            });
            this.blurEvt = input.addEventListener("blur", (evt) => {
                input.value = "";
                list = this.el.querySelector(".dropdown__content");
                clearTimeout(this.blurTimeout);
                this.blurTimeout = setTimeout(() => {
                    list.style.display = "none";
                }, 250);
                this.hidden = true;
            });
            this.clickEvt = toggleBtn.addEventListener("click", (evt) => {
                7
                this.hidden = !this.hidden;
                list.style.display = this.hidden ? "block" : "none";
            });
        },
        removeListeners() {
            removeEventListener("focus", this.focusEvt);
            removeEventListener("blur", this.blurEvt);
            removeEventListener("keyup", this.keyupEvt);
            removeEventListener("click", this.clickEvt);
        }
    },
    NumberInputPrecision: {},
    XNumberInputPrecision: {
        mounted() {
            this._updateValue();
            this.el.addEventListener('input', (event) => {
                const { data, inputType } = event;
                if (`${data}` === `${parseInt(data)}`){
                    this._updateValue();
                    return;
                }

                if (inputType === "deleteContentBackward"){
                    this._deviseValue();
                    return;
                }

                this._updateValue();
            });
        },
        _fixed_precision(val) {
            let input = this._replace_restricted_chars(val);
            input = parseInt(input);

            if(Math.floor(val) !== input){
                input = input / 100;
            }

            return input.toFixed(2);
        },
        _replace_restricted_chars(input) {
            return input.replaceAll(/\D+/g, '');
        },
        _updateValue(){
            this.el.value = this._fixed_precision(this.el.value);
        },
        _deviseValue(){
            this.el.value = this._fixed_precision(this.el.value);
        }
    },
    ActivePath: {
        mounted() {
            const { pathname } = window.location;
            if (pathname === this.el.getAttribute('href')) {
                this._addActive();
            } else {
                this._removeActive();
            }
        },
        destroyed() {
            this._removeActive();
        },
        _addActive() {
            this.el.classList.add('active');
        },
        _removeActive() {
            this.el.classList.remove('active');
        }
    },
}


export default Hooks;