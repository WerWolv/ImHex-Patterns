import std.io;
import std.core;

/*!
    The attributes library contains a set of attributes that can be used to annotate types with certain properties.
    To use an attribute, simply make your custom type inherit from the attribute type you want to use.

    For example, to make a type hidden, you can use the `Hidden` attribute like this:

    ```rust
    struct MyType : std::attr::Hidden {
        // ...
    };
    ```
*/

namespace auto std::attr {

    /**
        Attribute that marks a type as a literal type.
        This means the type behaves like a built-in type in the sense that it doesn't show its internal state and its display value is determined by a format function.
        It can also be transformed into a different built-in literal when used in an expression.
        @tparam FormatFunction The format function to use. The return value of this function is used to display the value of the literal and also determines the value returned when the literal is used in an expression.
    */
    struct Literal<auto FormatFunction> { }
    [[sealed, format_read(FormatFunction), transform(FormatFunction)]];

    /**
        Attribute that changes the name of the variable created from a type.
        @tparam Name The name of the variable created
    */
    struct Named<auto Name> { }
    [[name(Name)]];

    /**
        Attribute that adds a comment to the variable created from a type.
        @tparam Comment The comment to add
    */
    struct Commented<auto Comment> {}
    [[comment(Comment)]];

    /**
        Attribute that marks a type as hidden.
        This means variables of this type are not displayed in the UI.
    */
    struct Hidden {}
    [[hidden]];

    /**
        Attribute that marks a type as hidden and also hides it from the highlighter.
        This means variables of this type are don't display any highlighting in the UI but are still visible.
    */
    struct HighlightHidden {}
    [[highlight_hidden]];

    /**
        Attribute that marks a type as inline.
        Creating a variable of this type will not create a new layer but instead dump the contents of the type directly into the current layer.
    */
    struct Inlined {}
    [[inline]];

    /**
        Attribute that marks a type as sealed.
        Sealed types don't display their internal state in the UI.
    */
    struct Sealed {}
    [[sealed]];

}