using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptDomConstraintDefinition<T> : SqlScriptDomObject<T>,ISqlScriptConstraint
        where T : ConstraintDefinition
        {
        [UsedImplicitly][Field(Source="ConstraintIdentifier")] public SqlIdentifier Name { get; }
        public abstract SqlConstraintType Type { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptDomConstraintDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }