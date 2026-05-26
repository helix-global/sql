using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(DefaultConstraintDefinition))]
    internal class SqlFragmentDefaultConstraintDefinition : SqlFragmentConstraintDefinition<DefaultConstraintDefinition>,ISqlDefaultConstraint
        {
        public override SqlConstraintType Type { get{ return SqlConstraintType.Default; }}
        [UsedImplicitly][Field] public ISqlScriptScalarExpression Expression { get; }
        String ISqlDefaultConstraint.Expression { get { return Expression.ToString(); }}

        #region ctor{IServiceProvider,DefaultConstraintDefinition}
        public SqlFragmentDefaultConstraintDefinition(IServiceProvider context,DefaultConstraintDefinition source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }