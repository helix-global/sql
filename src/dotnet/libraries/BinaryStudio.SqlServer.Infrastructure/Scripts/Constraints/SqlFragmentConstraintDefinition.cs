using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentConstraintDefinition<T> : SqlFragmentObject<T>,ISqlScriptConstraint
        where T : ConstraintDefinition
        {
        [UsedImplicitly][Field(Source="ConstraintIdentifier")] public SqlIdentifier Name { get; }
        public abstract SqlConstraintType Type { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentConstraintDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            return;
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Name.ToString();
            }
        #endregion
        #region M:ToString(ISqlCase):String
        public virtual String ToString(ISqlCase Case)
            {
            return Name.ToString();
            }
        #endregion
        }
    }