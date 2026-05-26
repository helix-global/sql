using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(SqlCheckConstraint))]
    internal sealed class SqlScriptCheckConstraint : SqlScriptConstraint<SqlCheckConstraint>,ISqlCheckConstraint
        {
        [UsedImplicitly][Field] public Boolean NotForReplication { get; }
        [UsedImplicitly][Field] public ISqlScriptBooleanExpression Expression { get; }
        String ISqlCheckConstraint.Expression { get { return Expression.ToString(); }}

        #region ctor{IServiceProvider,SqlCheckConstraint}
        public SqlScriptCheckConstraint(IServiceProvider context,SqlCheckConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }