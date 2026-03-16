using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(CheckConstraintDefinition))]
    internal sealed class SqlFragmentCheckConstraintDefinition : SqlFragmentConstraintDefinition<CheckConstraintDefinition>
        {
        public override SqlConstraintType Type { get{ return SqlConstraintType.Check; }}

        #region ctor{IServiceProvider,CheckConstraintDefinition}
        public SqlFragmentCheckConstraintDefinition(IServiceProvider context,CheckConstraintDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }