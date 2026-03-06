using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDefaultConstraint))]
    internal sealed class SqlScriptDefaultConstraint : SqlScriptConstraint<SqlDefaultConstraint>
        {
        [UsedImplicitly][Field] public ISqlScriptScalarExpression Expression { get; }

        #region ctor{IServiceProvider,SqlDefaultConstraint}
        public SqlScriptDefaultConstraint(IServiceProvider context,SqlDefaultConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }