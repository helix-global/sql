using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [UsedImplicitly]
    [SqlScriptObject(typeof(CheckConstraintDefinition))]
    internal sealed class SqlFragmentCheckConstraintDefinition : SqlFragmentConstraintDefinition<CheckConstraintDefinition>,ISqlCheckConstraint
        {
        public override SqlConstraintType Type { get{ return SqlConstraintType.Check; }}
        [UsedImplicitly][Field] public ISqlScriptBooleanExpression CheckExpression { get; }
        String ISqlCheckConstraint.Expression { get { return CheckExpression.ToString(); }}

        #region ctor{IServiceProvider,CheckConstraintDefinition}
        public SqlFragmentCheckConstraintDefinition(IServiceProvider context,CheckConstraintDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }