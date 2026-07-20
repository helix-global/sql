using System;
using System.ComponentModel;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    /// <summary>
    /// Base class for all report objects.
    /// </summary>
    internal abstract class ReportComponentBase : FastReportComponentBase
        {
        /// <summary>
        /// Gets a value that determines which properties of the even style to use.
        /// </summary>
        /// <remarks>
        /// Usually you will need only the Fill property of the even style to be applied. If you want to 
        /// apply all style settings, set this property to <see cref="StylePriority.UseAll"/>.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000314)] public StylePriority EvenStylePriority { get; }
        /// <summary>
        /// Gets a script event name that will be fired after the object was filled with data.
        /// </summary>
        [UsedImplicitly][Field(Order=1000319)] public String AfterDataEvent { get; }
        /// <summary>
        /// Gets a script event name that will be fired after the object was printed in the preview page.
        /// </summary>
        [UsedImplicitly][Field(Order=1000318)] public String AfterPrintEvent { get; }
        /// <summary>
        /// Gets a script event name that will be fired before the object will be printed in the preview page.
        /// </summary>
        [UsedImplicitly][Field(Order=1000317)] public String BeforePrintEvent { get; }
        /// <summary>
        /// Gets a bookmark expression.
        /// </summary>
        /// <remarks>
        /// This property can contain any valid expression that returns a bookmark name. This can be, for example,
        /// a data column. To navigate to a bookmark, you have to use the <see cref="Hyperlink"/> property.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000307)] public String Bookmark { get; }
        /// <summary>
        /// Gets a script event name that will be fired when the user click the object in the preview window.
        /// </summary>
        [UsedImplicitly][Field(Order=1000320)] public String ClickEvent { get; }
        /// <summary>
        /// Gets a style name that will be applied to even band rows.
        /// </summary>
        /// <remarks>
        /// Style with this name must exist in the <see cref="FastReport.Styles"/> collection.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000313)] public String EvenStyle { get; }
        /// <summary>
        /// Gets a style name that will be applied to this object when the mouse pointer is over it.
        /// </summary>
        /// <remarks>
        /// Style with this name must exist in the <see cref="FastReport.Styles"/> collection.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000315)] public String HoverStyle { get; }
        /// <summary>
        /// Gets a script event name that will be fired when the user 
        /// clicks the mouse button in the preview window.
        /// </summary>
        [UsedImplicitly][Field(Order=1000323)] public String MouseDownEvent { get; }
        /// <summary>
        /// Gets a script event name that will be fired when the
        /// mouse enters the object's bounds in the preview window.
        /// </summary>
        [UsedImplicitly][Field(Order=1000324)] public String MouseEnterEvent { get; }
        /// <summary>
        /// Gets a script event name that will be fired when the
        /// mouse leaves the object's bounds in the preview window.
        /// </summary>
        [UsedImplicitly][Field(Order=1000325)] public String MouseLeaveEvent { get; }
        /// <summary>
        /// Gets a script event name that will be fired when the user 
        /// moves the mouse over the object in the preview window.
        /// </summary>
        [UsedImplicitly][Field(Order=1000321)] public String MouseMoveEvent { get; }
        /// <summary>
        /// Gets a script event name that will be fired when the user 
        /// releases the mouse button in the preview window.
        /// </summary>
        [UsedImplicitly][Field(Order=1000322)] public String MouseUpEvent { get; }
        /// <summary>
        /// Gets the style name.
        /// </summary>
        /// <remarks>
        /// Style is a set of common properties such as border, fill, font, text color. The <b>Report</b>
        /// has a set of styles in the <see cref="FastReport.Styles"/> property. 
        /// </remarks>
        [UsedImplicitly][Field(Order=1000312)] public virtual String Style { get; }
        /// <summary>
        /// Gets a bookmark expression.
        /// </summary>
        /// <remarks>
        /// This property can contain any valid expression that returns a bookmark name. This can be, for example,
        /// a data column. To navigate to a bookmark, you have to use the <see cref="Hyperlink"/> property.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000305)] public String Cursor { get; }
        /// <summary>
        /// Determines if the object can grow.
        /// </summary>
        /// <remarks>
        /// This property is applicable to the bands or text objects that can contain several text lines.
        /// If the property is set to <b>true</b>, object will grow to display all the information that it contains.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000308)] public Boolean CanGrow { get; }
        /// <summary>
        /// Determines if the object can shrink.
        /// </summary>
        /// <remarks>
        /// This property is applicable to the bands or text objects that can contain several text lines.
        /// If the property is set to true, object can shrink to remove the unused space.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000309)] public Boolean CanShrink { get; }
        /// <summary>
        /// Gets a value that determines if the object can be exported.
        /// </summary>
        [UsedImplicitly][Field(Order=1000302)][DefaultValue(true)] public Boolean Exportable { get; } = true;
        /// <summary>
        /// Determines if the object must grow to the band's bottom side.
        /// </summary>
        /// <remarks>
        /// If the property is set to true, object grows to the bottom side of its parent. This is useful if
        /// you have several objects on a band, and some of them can grow or shrink.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000310)] public Boolean GrowToBottom { get; }
        /// <summary>
        /// Gets a value that determines if the object can be printed on the printer.
        /// </summary>
        /// <remarks>
        /// Object with Printable = <b>false</b> is still visible in the preview window, but not on the prinout.
        /// If you want to hide an object in the preview, set the <see cref="FastReportComponentBase.Visible"/> property to <b>false</b>.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000301)][DefaultValue(true)] public Boolean Printable { get; } = true;
        /// <summary>
        /// Gets a value that determines where to print the object.
        /// </summary>
        /// <remarks>
        /// See the <see cref="Reports.PrintOn"/> enumeration for details.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000316)][DefaultValue(PrintOn.FirstPage|PrintOn.LastPage|PrintOn.OddPages|PrintOn.EvenPages|PrintOn.RepeatedBand|PrintOn.SinglePage)] public PrintOn PrintOn { get; } = PrintOn.FirstPage|PrintOn.LastPage|PrintOn.OddPages|PrintOn.EvenPages|PrintOn.RepeatedBand|PrintOn.SinglePage;
        /// <summary>
        /// Gets or sets a shift mode of the object.
        /// </summary>
        /// <remarks>
        /// See <see cref="Reports.ShiftMode"/> enumeration for details.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000311)][DefaultValue(ShiftMode.Always)] public ShiftMode ShiftMode { get; } = ShiftMode.Always;
        /// <summary>
        /// Gets an object's border.
        /// </summary>
        [UsedImplicitly][Field(Order=1000303)][DefaultValue(typeof(FastReportBorder),null)] public FastReportBorder Border { get; } = new FastReportBorder();
        /// <summary>
        /// Gets an object's fill.
        /// </summary>
        /// <remarks>
        /// The fill can be one of the following types: <see cref="FastReportSolidFill"/>, <see cref="FastReportLinearGradientFill"/>, 
        /// <see cref="FastReportPathGradientFill"/>, <see cref="FastReportHatchFill"/>.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000304)][DefaultValue(typeof(FastReportSolidFill),"Color=Transparent")] public FastReportFillBase Fill { get; } = new FastReportSolidFill(Color.Transparent);
        /// <summary>
        /// Gets a hyperlink.
        /// </summary>
        /// <remarks>
        /// <para>The hyperlink is used to define clickable objects in the preview. 
        /// When you click such object, you may navigate to the external url, the page number, 
        /// the bookmark defined by other report object, or display the external report. 
        /// Set the <b>Kind</b> property of the hyperlink to select appropriate behavior.</para>
        /// <para>Usually you should set the <b>Expression</b> property of the hyperlink to
        /// any valid expression that will be calculated when this object is about to print.
        /// The value of an expression will be used for navigation.</para>
        /// <para>If you want to navigate to
        /// something fixed (URL or page number, for example) you also may set the <b>Value</b>
        /// property instead of <b>Expression</b>.</para>
        /// </remarks>
        [UsedImplicitly][Field(Order=1000306)][DefaultValue(typeof(FastReportHyperlink),null)] public FastReportHyperlink Hyperlink { get; } = new FastReportHyperlink();
        }
    }
