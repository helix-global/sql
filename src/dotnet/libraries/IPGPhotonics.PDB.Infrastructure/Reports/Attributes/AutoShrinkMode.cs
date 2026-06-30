using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    /// <summary>
    /// Specifies the behavior of the <b>AutoShrink</b> feature of <b>TextObject</b>.
    /// </summary>
    [TypeConverter(typeof(SqlEnumConverter<AutoShrinkMode>))]
    public enum AutoShrinkMode
        {
        #region None
        /// <summary>
        /// AutoShrink is disabled.
        /// </summary>
        None,
        #endregion
        #region FontSize
        /// <summary>
        /// AutoShrink decreases the <b>Font.Size</b> property of the <b>TextObject</b>.
        /// </summary>
        FontSize,
        #endregion
        #region FontWidth
        /// <summary>
        /// AutoShrink decreases the <b>FontWidthRatio</b> property of the <b>TextObject</b>.
        /// </summary>
        FontWidth
        #endregion
        }
    }