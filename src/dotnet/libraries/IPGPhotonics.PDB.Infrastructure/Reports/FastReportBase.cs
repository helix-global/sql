using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    /// <summary>
    /// Represents the root class of the FastReport object's hierarhy.
    /// </summary>
    internal abstract class FastReportBase : FastReportObject
        {
        /// <summary>
        /// Gets the name of the object.
        /// </summary>
        /// <remarks>
        ///   <para>Name of the report object must contain alpha, digit, underscore symbols only.
        ///     Data objects such as <b>Variable</b>, <b>TableDataSource</b>
        ///     etc. can have any characters in they names. Each component must have unique
        ///     name.</para>
        /// </remarks>
        [UsedImplicitly][Field(Order=1000101)] public virtual String Name { get; }
        /// <summary>
        /// Gets the Z-order of the object.
        /// </summary>
        /// <remarks>
        /// The Z-order is also called "creation order". It is the index of an object in the parent's objects list.
        /// For example, put two text objects on a band. First object will have <b>ZOrder</b> = 0, second = 1. Setting the
        /// second object's <b>ZOrder</b> to 0 will move it to the back of the first text object.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000102)] public Int32 ZOrder { get; }
        /// <summary>
        /// Gets the flags that restrict some actions in the designer.
        /// </summary>
        /// <remarks>
        /// Use this property to restrict some user actions like move, resize, edit, delete. For example, if
        /// <b>Restriction.DontMove</b> flag is set, user cannot move the object in the designer.
        /// </remarks>
        [UsedImplicitly][Field(Order=1000103)] public Restrictions Restrictions { get; }

        #region M:ToString:String
        public override String ToString()
            {
            return $"{((IFastReportClassObjectLegacy)this).ClassName}:Name={Name}";
            }
        #endregion
        }
    }
