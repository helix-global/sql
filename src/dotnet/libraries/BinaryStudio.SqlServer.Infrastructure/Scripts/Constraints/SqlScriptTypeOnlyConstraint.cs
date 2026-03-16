using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlConstraint))]
    internal sealed class SqlScriptTypeOnlyConstraint : SqlScriptConstraint<SqlConstraint>
        {
        #region ctor{IServiceProvider,SqlConstraint}
        public SqlScriptTypeOnlyConstraint(IServiceProvider context,SqlConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }