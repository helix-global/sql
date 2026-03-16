using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    /// <summary>
    /// This class represents a parameter that can be passed into a procedure.
    /// </summary>
    [SqlScriptObject(typeof(ProcedureParameter))]
    internal sealed class SqlFragmentProcedureParameter : SqlFragmentDeclareVariableElement<ProcedureParameter>
        {
        #region P:IsVarying:Boolean
        /// <summary>
        /// Shows if VARYING is defined.
        /// </summary>
        [UsedImplicitly][Field] public Boolean IsVarying { get; }
        #endregion
        #region P:Modifier:ParameterModifier
        /// <summary>
        /// Shows if OUTPUT or READONLY is defined.
        /// </summary>
        [UsedImplicitly][Field] public ParameterModifier Modifier { get; }
        #endregion

        #region ctor{IServiceProvider,ProcedureParameter}
        public SqlFragmentProcedureParameter(IServiceProvider context,ProcedureParameter source)
            : base(context,source)
            {
            }
        #endregion
        }
    }