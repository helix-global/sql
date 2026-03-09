using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCheckConstraint))]
    internal sealed class SqlScriptCheckConstraint : SqlScriptConstraint<SqlCheckConstraint>
        {
        [UsedImplicitly][Field] public Boolean NotForReplication { get; }
        [UsedImplicitly][Field] public ISqlScriptBooleanExpression Expression { get; }

        #region ctor{IServiceProvider,SqlCheckConstraint}
        public SqlScriptCheckConstraint(IServiceProvider context,SqlCheckConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }