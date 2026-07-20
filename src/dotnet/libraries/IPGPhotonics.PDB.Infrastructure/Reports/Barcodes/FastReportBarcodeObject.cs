using System;
using System.ComponentModel;
using System.Windows;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    /// <summary>
    /// Represents a barcode object.
    /// </summary>
    /// <remarks>
    /// The instance of this class represents a barcode. Here are some common 
    /// actions that can be performed with this object:
    /// <list type="bullet">
    ///   <item>
    ///     <description>To select the type of barcode, use the <see cref="Barcode"/> property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <description>To specify a static barcode data, use the <see cref="Text"/> property.
    ///       You also may use the <see cref="DataColumn"/> or <see cref="Expression"/> properties 
    ///       to specify dynamic value for a barcode.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <description>To set a barcode orientation, use the <see cref="Angle"/> property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <description>To specify the size of barcode, set the <see cref="AutoSize"/> property
    ///       to <see langword="true"/> and use the <see cref="Zoom"/> property to zoom the barcode. 
    ///       If <see cref="AutoSize"/> property is set to <see langword="false"/>, you need to specify the
    ///       size using the <see cref="FastReportComponentBase.Width"/> and 
    ///       <see cref="FastReportComponentBase.Height"/> properties.
    ///     </description>
    ///   </item>
    /// </list>
    /// </remarks>
    [FastReportClass("BarcodeObject")]
    internal class FastReportBarcodeObject : ReportComponentBase
        {
        /// <summary>
        /// Gets a data column name bound to this control.
        /// </summary>
        /// <remarks>
        /// Value must be in the form "Datasource.Column".
        /// </remarks>
        [UsedImplicitly][Field(Order=1000403)] public String DataColumn { get; }
        /// <summary>
        /// Gets the barcode data.
        /// </summary>
        [UsedImplicitly][Field(Order=1000405)] public String Text { get; }
        /// <summary>
        /// Gets an expression that contains the barcode data.
        /// </summary>
        [UsedImplicitly][Field(Order=1000404)] public String Expression { get; }
        /// <summary>
        /// Gets the text that will be displayed if the barcode data is empty.
        /// </summary>
        [UsedImplicitly][Field(Order=1000410)] public String NoDataText { get; }
        /// <summary>
        /// Gets the angle of barcode, in degrees.
        /// </summary>
        [UsedImplicitly][Field(Order=1000401)] public Int32 Angle { get; }
        /// <summary>
        /// Gets a value that determines whether the barcode should handle its width automatically.
        /// </summary>
        [UsedImplicitly][Field(Order=1000402)][DefaultValue(true)] public Boolean AutoSize { get; } = true;
        /// <summary>
        /// Gets a value that determines whether it is necessary to hide the object if the
        /// barcode data is empty.
        /// </summary>
        [UsedImplicitly][Field(Order=1000409)][DefaultValue(true)] public Boolean HideIfNoData { get; } = true;
        /// <summary>
        /// Gets a value that indicates if the barcode should display a human-readable text.
        /// </summary>
        [UsedImplicitly][Field(Order=1000406)][DefaultValue(true)] public Boolean ShowText { get; } = true;
        /// <summary>
        /// Gets a zoom of the barcode.
        /// </summary>
        [UsedImplicitly][Field(Order=1000408,ConverterCulture="en-US")][DefaultValue(1f)] public Single Zoom { get; } = 1f;
        /// <summary>
        /// Gets the barcode type.
        /// </summary>
        [UsedImplicitly][Field(Order=1000411)][DefaultValue(typeof(FastReportBarcode39),"CalcCheckSum=true")] public FastReportBarcodeBase Barcode { get; } = new FastReportBarcode39();
        /// <summary>
        /// Gets padding within the <see cref="FastReportBarcodeObject"/>.
        /// </summary>
        [UsedImplicitly][Field(Order=1000407,Converter=typeof(FastReportThicknessConverter))] public Thickness Padding { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }
