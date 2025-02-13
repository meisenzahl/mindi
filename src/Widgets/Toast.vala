/*-
 * Copyright (c) 2016-2017 elementary LLC. (https://elementary.io)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the Lesser GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Artem Anufrij <artem.anufrij@live.de>
 *              Daniel Foré <daniel@elementary.io>
 *
 */

namespace Mindi.Widgets {
    public class Toast : Gtk.Revealer {
        public signal void default_action ();
        private Gtk.Label notification_label;
        private Gtk.Button default_action_button;
        private string _title;
        private uint timeout_id;
        public string title {
            get {
                return _title;
            }
            construct set {
                if (notification_label != null) {
                    notification_label.label = value;
                }
                _title = value;
            }
        }

        public Toast (string title) {
            Object (title: title);
        }

        construct {
            margin = 3;
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.START;

            default_action_button = new Gtk.Button ();
            default_action_button.visible = false;
            default_action_button.no_show_all = true;
            default_action_button.clicked.connect (() => {
                reveal_child = false;
                if (timeout_id != 0) {
                    Source.remove (timeout_id);
                    timeout_id = 0;
                }
                default_action ();
            });

            notification_label = new Gtk.Label (title);
            notification_label.ellipsize = Pango.EllipsizeMode.END;
            notification_label.max_width_chars = 42;

            var notification_box = new Gtk.Grid ();
            notification_box.column_spacing = 12;
            notification_box.add (notification_label);
            notification_box.add (default_action_button);

            var notification_frame = new Gtk.Frame (null);
            notification_frame.get_style_context ().add_class ("app-notification");
            notification_frame.add (notification_box);

            add (notification_frame);
        }

        public void set_default_action (string? label) {
            if (label == "" || label == null) {
                default_action_button.no_show_all = true;
                default_action_button.visible = false;
            } else {
                default_action_button.no_show_all = false;
                default_action_button.visible = true;
            }
            default_action_button.label = label;
        }

        public void send_notification () {
                reveal_child = true;

                uint duration;

                if (default_action_button.visible) {
                    duration = 10;
                } else {
                    duration = 4500;
                }

                timeout_id = GLib.Timeout.add (duration, () => {
                    reveal_child = false;
                    timeout_id = 0;
                    return false;
                });
        }
    }
}
