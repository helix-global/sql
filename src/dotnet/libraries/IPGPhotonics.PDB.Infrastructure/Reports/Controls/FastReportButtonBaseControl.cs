using System;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    /// <summary>
    /// Implements base behavior of button controls.
    /// </summary>
    internal abstract class FastReportButtonBaseControl : FastReportDataFilterBaseControl
        {
        /// <summary>
        /// Gets the image that is displayed on a button control.
        /// </summary>
        [UsedImplicitly][Field(Order=1000602,Converter=typeof(SqlBase64ArrayConverter))] public Byte[] Image { get; }
        /// <summary>
        /// Gets a value that indicates whether the control resizes based on its contents.
        /// Wraps the <see cref="System.Windows.Forms.ButtonBase.AutoSize"/> property.
        /// </summary>
        [UsedImplicitly][Field(Order=1000601)] public Boolean AutoSize { get; }
        /// <summary>
        /// Gets the alignment of the text on the button control.
        /// Wraps the <see cref="System.Windows.Forms.ButtonBase.TextAlign"/> property.
        /// </summary>
        [UsedImplicitly][Field(Order=1000604,Converter=typeof(SqlEnumConverter<ContentAlignment>))][DefaultValue(ContentAlignment.MiddleLeft)] public ContentAlignment TextAlign { get; } = ContentAlignment.MiddleLeft;
        /// <summary>
        /// Gets the position of text and image relative to each other.
        /// Wraps the <see cref="System.Windows.Forms.ButtonBase.TextImageRelation"/> property.
        /// </summary>
        [UsedImplicitly][Field(Order=1000605,Converter=typeof(SqlEnumConverter<TextImageRelation>))] public TextImageRelation TextImageRelation { get; }
        /// <summary>
        /// Gets the alignment of the image on the button control.
        /// Wraps the <see cref="System.Windows.Forms.ButtonBase.ImageAlign"/> property.
        /// </summary>
        [UsedImplicitly][Field(Order=1000603,Converter=typeof(SqlEnumConverter<ContentAlignment>))][DefaultValue(ContentAlignment.MiddleCenter)] public ContentAlignment ImageAlign { get; } = ContentAlignment.MiddleCenter;

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }