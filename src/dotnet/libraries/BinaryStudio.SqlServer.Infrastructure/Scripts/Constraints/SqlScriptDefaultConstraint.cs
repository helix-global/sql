using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(SqlDefaultConstraint))]
    internal sealed class SqlScriptDefaultConstraint : SqlScriptConstraint<SqlDefaultConstraint>,ISqlDefaultConstraint
        {
        [UsedImplicitly][Field] public ISqlScriptScalarExpression Expression { get; }
        String ISqlDefaultConstraint.Expression { get { return Expression.ToString(); }}

        #region ctor{IServiceProvider,SqlDefaultConstraint}
        public SqlScriptDefaultConstraint(IServiceProvider context,SqlDefaultConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }