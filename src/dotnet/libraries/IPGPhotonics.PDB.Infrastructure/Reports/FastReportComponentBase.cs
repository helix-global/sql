using System;
using System.ComponentModel;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    /// <summary>
    /// Class that implements some object's properties such as location, size and visibility.
    /// </summary>
    internal abstract class FastReportComponentBase : FastReportBase
        {
        /// <summary>
        /// Gets the left coordinate of the object in relation to its container.
        /// </summary>
        [UsedImplicitly][Field(Order=1000201,ConverterCulture="en-US")] public Single Left { get; }
        /// <summary>
        /// Gets the top coordinate of the object in relation to its container.
        /// </summary>
        [UsedImplicitly][Field(Order=1000202,ConverterCulture="en-US")] public Single Top { get; }
        /// <summary>
        /// Gets the width of the object.
        /// </summary>
        [UsedImplicitly][Field(Order=1000203,ConverterCulture="en-US")] public virtual Single Width { get; }
        /// <summary>
        /// Gets the height of the object.
        /// </summary>
        [UsedImplicitly][Field(Order=1000204,ConverterCulture="en-US")] public virtual Single Height { get; }
        /// <summary>
        /// Gets the edges of the container to which a control is bound and determines how a control
        /// is resized with its parent.
        /// </summary>
        /// <remarks>
        /// <para>Use the Anchor property to define how a control is automatically resized as its parent control
        /// is resized. Anchoring a control to its parent control ensures that the anchored edges remain in the 
        /// same position relative to the edges of the parent control when the parent control is resized.</para>
        /// <para>You can anchor a control to one or more edges of its container. For example, if you have a band 
        /// with a <b>TextObject</b> whose <b>Anchor</b> property value is set to <b>Top, Bottom</b>, the <b>TextObject</b> is stretched to 
        /// maintain the anchored distance to the top and bottom edges of the band as the height of the band 
        /// is increased.</para>
        /// </remarks>
        [UsedImplicitly][Field(Order=1000206,Converter=typeof(SqlEnumConverter<AnchorStyles>))][DefaultValue(AnchorStyles.Left|AnchorStyles.Top)] public AnchorStyles Anchor { get; } = AnchorStyles.Left|AnchorStyles.Top;
        /// <summary>
        /// Gets which control borders are docked to its parent control and determines how a control 
        /// is resized with its parent.
        /// </summary>
        /// <remarks>
        /// <para>Use the <b>Dock</b> property to define how a control is automatically resized as its parent control is 
        /// resized. For example, setting Dock to <c>DockStyle.Left</c> causes the control to align itself with the 
        /// left edges of its parent control and to resize as the parent control is resized.</para>
        /// <para>A control can be docked to one edge of its parent container or can be docked to all edges and 
        /// fill the parent container.</para>
        /// </remarks>
        [UsedImplicitly][Field(Order=1000205,Converter=typeof(SqlEnumConverter<DockStyle>))] public DockStyle Dock { get; }
        /// <summary>
        /// Gets a value indicating whether the object is displayed in the preview window.
        /// </summary>
        [UsedImplicitly][Field(Order=1000207)][DefaultValue(true)] public Boolean Visible { get; } = true;
        /// <summary>
        /// Gets a group index.
        /// </summary>
        /// <remarks>
        /// Group index is used to group objects in the designer (using "Group" button). When you select
        /// any object in a group, entire group becomes selected.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000208)] public Int32 GroupIndex { get; }
        }
    }
